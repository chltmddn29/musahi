import {setGlobalOptions} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
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
const sgisConsumerKey = defineSecret("SGIS_CONSUMER_KEY");
const sgisConsumerSecret = defineSecret("SGIS_CONSUMER_SECRET");

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

function getSeverityBand(severity: string): "critical" | "safe" {
    return severity === "안전안내" ? "safe" : "critical";
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

// SGIS consumer_key/secret은 클라이언트에 절대 포함하지 않고, 이 함수 안에서만
// 시크릿으로 보관한다. 앱은 이 함수만 호출해 SGIS 인증/조회를 대신 수행시킨다.
let sgisAccessToken: string | null = null;
let sgisAccessTokenExpiresAt: number | null = null;

async function ensureSgisAccessToken(consumerKey: string, consumerSecret: string): Promise<string> {
    const now = Date.now();
    if (sgisAccessToken && sgisAccessTokenExpiresAt && now < sgisAccessTokenExpiresAt) {
        return sgisAccessToken;
    }

    const response = await axios.get(
        "https://sgisapi.kostat.go.kr/OpenAPI3/auth/authentication.json",
        {
            params: { consumer_key: consumerKey, consumer_secret: consumerSecret },
            timeout: 15000,
        }
    );
    const body = response.data;

    if (body.errCd !== 0) {
        throw new Error(`SGIS 인증 실패: ${body.errMsg}`);
    }

    sgisAccessToken = body.result.accessToken;
    // SGIS 액세스 토큰 유효기간은 보통 4시간이나, 여유를 두고 3시간 후 만료로 처리한다.
    sgisAccessTokenExpiresAt = now + 3 * 60 * 60 * 1000;
    return sgisAccessToken as string;
}

// 인스턴스별 최소한의 rate limit이다. 분산 환경에서 완전한 보장은 아니지만,
// 단일 호출자가 SGIS quota와 함수 비용을 소진시키는 것을 완화한다.
const SGIS_RATE_LIMIT_WINDOW_MS = 60 * 1000;
const SGIS_RATE_LIMIT_MAX_REQUESTS = 30;
const sgisRequestTimestamps = new Map<string, number[]>();

function isSgisRateLimited(clientId: string): boolean {
    const now = Date.now();
    const windowStart = now - SGIS_RATE_LIMIT_WINDOW_MS;
    const timestamps = (sgisRequestTimestamps.get(clientId) ?? []).filter(
        (ts) => ts > windowStart
    );
    if (timestamps.length >= SGIS_RATE_LIMIT_MAX_REQUESTS) {
        sgisRequestTimestamps.set(clientId, timestamps);
        return true;
    }
    timestamps.push(now);
    sgisRequestTimestamps.set(clientId, timestamps);
    return false;
}

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

        if (isSgisRateLimited(req.ip ?? "unknown")) {
            res.status(429).json({ error: "요청이 너무 많습니다. 잠시 후 다시 시도하세요." });
            return;
        }

        try {
            const cd = typeof req.query.cd === "string" ? req.query.cd : undefined;
            const accessToken = await ensureSgisAccessToken(
                sgisConsumerKey.value(),
                sgisConsumerSecret.value()
            );

            const response = await axios.get(
                "https://sgisapi.kostat.go.kr/OpenAPI3/addr/stage.json",
                {
                    params: { accessToken, ...(cd ? { cd } : {}) },
                    timeout: 15000,
                }
            );
            const body = response.data;

            if (body.errCd !== 0) {
                logger.warn("SGIS 지역 조회 실패", { errCd: body.errCd, errMsg: body.errMsg });
                res.status(502).json({ error: body.errMsg ?? "지역 조회 실패" });
                return;
            }

            res.status(200).json({ result: body.result });
        } catch (error) {
            // 캐시된 토큰이 서버 쪽에서 만료됐을 수 있으니 다음 요청에 재발급하도록 초기화한다.
            sgisAccessToken = null;
            sgisAccessTokenExpiresAt = null;
            logger.error("SGIS 지역 조회 중 오류", { error });
            res.status(502).json({ error: "지역 조회 실패" });
        }
    }
);