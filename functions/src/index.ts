import {setGlobalOptions} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

admin.initializeApp();
const db = getFirestore(admin.app(), "musahi");
const messaging = getMessaging();

setGlobalOptions({ maxInstances: 10 });

const disasterApiKey = defineSecret("DISASTER_API_KEY");

function getTodayYYYYMMDD(): string {
    const now = new Date();
    const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
    const yyyy = kst.getUTCFullYear();
    const mm = String(kst.getUTCMonth() + 1).padStart(2, "0");
    const dd = String(kst.getUTCDate()).padStart(2, "0");
    return `${yyyy}${mm}${dd}`;
}

function getSeverity(emrgStepNm: string): "위급" | "긴급" | "안전안내" {
    if (emrgStepNm.includes("위급")) return "위급";
    if (emrgStepNm.includes("긴급")) return "긴급";
    return "안전안내";
}

async function fetchDisasterMessagesPage(
    apiKey: string,
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
                        crtDt: getTodayYYYYMMDD(),
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
            logger.warn(`API 호출 실패, 재시도 (${attempt + 1}/${retries})`, { error, page });
            await new Promise((resolve) => setTimeout(resolve, 2000));
        }
    }
    throw lastError;
}

async function fetchAllTodayMessages(apiKey: string): Promise<any[]> {
    const numOfRows = 100;
    let page = 1;
    let allMessages: any[] = [];
    let totalCount = 0;

    while (true) {
        const response = await fetchDisasterMessagesPage(apiKey, page, numOfRows);
        const body = response.data?.body ?? [];
        totalCount = response.data?.totalCount ?? 0;

        allMessages = allMessages.concat(body);

        logger.info(`페이지 ${page} 조회 완료 (누적 ${allMessages.length}/${totalCount})`);

        if (body.length === 0 || allMessages.length >= totalCount) break;
        page++;
    }

    return allMessages;
}

async function publishMessage(msg: any) {
    const severity = getSeverity(msg.EMRG_STEP_NM ?? "");
    const regionIds: string[] = (msg.RCPTN_RGN_ID ?? "")
        .split(",")
        .map((id: string) => id.trim())
        .filter((id: string) => id.length > 0);

    if (regionIds.length === 0) {
        logger.warn("지역 코드 없는 메시지, 발행 스킵", { sn: msg.SN });
        return;
    }

    const topics = ["all", ...regionIds];  // "all" 추가

    const publishPromises = topics.map((topicSuffix) => {
        const topic = `region_${topicSuffix}`;
        return messaging.send({
            topic,
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
        });
    });

    await Promise.allSettled(publishPromises);
    logger.info(`FCM 발행 완료 (SN: ${msg.SN}, 심각도: ${severity}, 지역: ${regionIds.join(",")})`);
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
            const body = await fetchAllTodayMessages(disasterApiKey.value());

            if (body.length === 0) {
                logger.info("오늘자 재난문자 없음");
                return;
            }

            const lastProcessedDoc = await db.collection("system").doc("lastProcessed").get();
            const lastSn: number = lastProcessedDoc.exists ? lastProcessedDoc.data()?.sn ?? 0 : 0;

            const newMessages = body.filter((msg: any) => msg.SN > lastSn);

            if (newMessages.length === 0) {
                logger.info("새 재난문자 없음", { lastSn });
                return;
            }

            logger.info(`새 재난문자 ${newMessages.length}건 발견, FCM 발행 시작`);

            for (const msg of newMessages) {
                await publishMessage(msg);
                await collectRegionCodes(msg);
                await saveMessage(msg);
            }

            const maxSn = Math.max(...body.map((msg: any) => msg.SN));
            await db.collection("system").doc("lastProcessed").set({ sn: maxSn });

        } catch (error) {
            logger.error("재난문자 API 호출 실패", { error });
        }
    }
);