import {setGlobalOptions} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import {createShelterFunctions} from "./shelters";
import {safeErrorSummary} from "./errors";
import {createRateLimiter, rejectIfLimited} from "./rate_limit";
import {getQueryDates, isStaleMessage, processNewMessages, sendToAllTopics} from "./disaster_poll";
import {sgisConsumerKey, sgisConsumerSecret, sgisGet} from "./sgis";

admin.initializeApp();
const db = getFirestore(admin.app(), "musahi");
const messaging = getMessaging();

setGlobalOptions({ maxInstances: 10 });

const disasterApiKey = defineSecret("DISASTER_API_KEY");

function getSeverity(emrgStepNm: string): "위급" | "긴급" | "안전안내" {
    if (emrgStepNm.includes("위급")) return "위급";
    if (emrgStepNm.includes("긴급")) return "긴급";
    return "안전안내";
}

function getSeverityBand(severity: string): "critical" | "safe" {
    return severity === "안전안내" ? "safe" : "critical";
}

async function fetchDisasterMessagesPage(
    apiKey: string,
    crtDt: string,
    page: number,
    numOfRows: number,
    retries = 2
): Promise<any> {
    let lastError: unknown;
    for (let attempt = 0; attempt <= retries; attempt++) {
        try {
            const response = await axios.get(
                "https://www.safetydata.go.kr/V2/api/DSSP-IF-00247",
                {
                    params: {
                        serviceKey: apiKey,
                        returnType: "json",
                        crtDt,
                        numOfRows,
                        pageNo: page,
                    },
                    timeout: 15000,
                }
            );
            return response;
        } catch (error) {
            lastError = error;
            if (attempt === retries) throw error;
            logger.warn(`API 호출 실패, 재시도 (${attempt + 1}/${retries})`, { ...safeErrorSummary(error), crtDt, page });
            await new Promise((resolve) => setTimeout(resolve, 2000));
        }
    }
    throw lastError;
}

async function fetchMessagesOf(apiKey: string, crtDt: string): Promise<any[]> {
    const numOfRows = 100;
    let page = 1;
    let allMessages: any[] = [];
    let totalCount = 0;

    while (true) {
        const response = await fetchDisasterMessagesPage(apiKey, crtDt, page, numOfRows);
        const body = response.data?.body ?? [];
        totalCount = response.data?.totalCount ?? 0;

        allMessages = allMessages.concat(body);

        logger.info(`${crtDt} 페이지 ${page} 조회 완료 (누적 ${allMessages.length}/${totalCount})`);

        if (body.length === 0 || allMessages.length >= totalCount) break;
        page++;
    }

    return allMessages;
}

async function fetchAllMessages(apiKey: string): Promise<any[]> {
    const messages: any[] = [];
    for (const crtDt of getQueryDates()) {
        messages.push(...await fetchMessagesOf(apiKey, crtDt));
    }
    return messages;
}

async function publishMessage(msg: any) {
    const severity = getSeverity(msg.EMRG_STEP_NM ?? "");
    const band = getSeverityBand(severity);
    const regionIds: string[] = (msg.RCPTN_RGN_ID ?? "")
        .split(",")
        .map((id: string) => id.trim())
        .filter((id: string) => id.length > 0);

    if (regionIds.length === 0) {
        logger.warn("지역 코드 없는 메시지, 발행 스킵", { sn: msg.SN });
        return;
    }

    const topics = ["all", ...regionIds.map((id) => `${id}_${band}`)];

    await sendToAllTopics(topics, (suffix) => messaging.send({
        topic: `region_${suffix}`,
        notification: {
            title: `[${severity}] ${msg.RCPTN_RGN_NM?.trim() ?? ""}`,
            body: msg.MSG_CN ?? "",
        },
        data: {
            sn: String(msg.SN),
            severity,
            emrgStepNm: msg.EMRG_STEP_NM ?? "",
            dstSeNm: msg.DST_SE_NM ?? "",
            rcptnRgnNm: msg.RCPTN_RGN_NM ?? "",
            crtDt: msg.CRT_DT ?? "",
        },
    }));
    logger.info(`FCM 발행 완료 (SN: ${msg.SN}, 심각도: ${severity}, 밴드: ${band}, 지역: ${regionIds.join(",")})`);
}

async function collectRegionCodes(msg: any) {
    const ids: string[] = (msg.RCPTN_RGN_ID ?? "")
        .split(",")
        .map((s: string) => s.trim())
        .filter((s: string) => s.length > 0);
    const names: string[] = (msg.RCPTN_RGN_NM ?? "")
        .split(",")
        .map((s: string) => s.trim())
        .filter((s: string) => s.length > 0);

    if (ids.length === 0 || ids.length !== names.length) {
        return;
    }

    const batch = db.batch();
    for (let i = 0; i < ids.length; i++) {
        const ref = db.collection("regions").doc(ids[i]);
        batch.set(ref, { code: ids[i], name: names[i] }, { merge: true });
    }
    await batch.commit();
}

async function saveMessage(msg: any) {
    const regionIds: string[] = (msg.RCPTN_RGN_ID ?? "")
        .split(",")
        .map((s: string) => s.trim())
        .filter((s: string) => s.length > 0);

    await db.collection("messages").doc(String(msg.SN)).set({
        sn: msg.SN,
        severity: getSeverity(msg.EMRG_STEP_NM ?? ""),
        emrgStepNm: msg.EMRG_STEP_NM ?? "",
        dstSeNm: msg.DST_SE_NM ?? "",
        rcptnRgnNm: msg.RCPTN_RGN_NM ?? "",
        msgCn: msg.MSG_CN ?? "",
        crtDt: msg.CRT_DT ?? "",
        regionIds,
    });
}

export const pollDisasterAlerts = onSchedule(
    {
        schedule: "every 5 minutes",
        region: "asia-northeast3",
        secrets: [disasterApiKey],
    },
    async (event) => {
        try {
            const body = await fetchAllMessages(disasterApiKey.value());

            if (body.length === 0) {
                logger.info("오늘자 재난문자 없음");
                return;
            }

            const lastProcessedDoc = await db.collection("system").doc("lastProcessed").get();
            const lastSn: number = lastProcessedDoc.exists ? lastProcessedDoc.data()?.sn ?? 0 : 0;

            const processedSn = await processNewMessages(
                body,
                lastSn,
                async (msg) => {
                    // 멱등한 저장을 먼저 하고 푸시를 마지막에 보낸다. 앞 단계가 실패해 재시도해도 푸시가 중복되지 않는다.
                    await saveMessage(msg);
                    await collectRegionCodes(msg);
                    await publishMessage(msg);
                },
                (msg, error) => logger.error(
                    isStaleMessage(msg.CRT_DT) ? "재난문자 처리 실패, 1시간이 지나 건너뜀" : "재난문자 처리 실패, 다음 폴링에서 다시 시도",
                    {sn: msg.SN, ...safeErrorSummary(error)},
                ),
                (msg) => isStaleMessage(msg.CRT_DT),
            );

            if (processedSn === lastSn) {
                logger.info("새로 처리한 재난문자 없음", { lastSn });
                return;
            }
            logger.info(`재난문자 처리 완료 (SN ${lastSn} → ${processedSn})`);
            // 실패해 멈췄더라도 그 앞까지 처리한 SN은 저장해 중복 발송을 막는다.
            await db.collection("system").doc("lastProcessed").set({ sn: processedSn });

        } catch (error) {
            logger.error("재난문자 API 호출 실패", safeErrorSummary(error));
        }
    }
);

const sgisRateLimiter = createRateLimiter(60 * 1000, 30);

export const sgisRegions = onRequest(
    {
        region: "asia-northeast3",
        secrets: [sgisConsumerKey, sgisConsumerSecret],
    },
    async (req, res) => {
        res.set("Access-Control-Allow-Origin", "*");
        if (req.method === "OPTIONS") {
            res.set("Access-Control-Allow-Methods", "GET");
            res.set("Access-Control-Allow-Headers", "Content-Type");
            res.status(204).send("");
            return;
        }

        if (rejectIfLimited(sgisRateLimiter, req, res)) return;

        try {
            const cd = typeof req.query.cd === "string" ? req.query.cd : undefined;
            const result = await sgisGet("addr/stage.json", cd ? { cd } : {});
            res.status(200).json({ result });
        } catch (error) {
            logger.error("SGIS 지역 조회 중 오류", safeErrorSummary(error));
            res.status(502).json({ error: "지역 조회 실패" });
        }
    }
);
export const {syncShelters, nearbyShelters, disasterAreas} = createShelterFunctions(db);
export {walkingRoute} from "./walking_route";
