import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";
import {Firestore} from "firebase-admin/firestore";
import {safeErrorSummary} from "./errors";
import {toNumber} from "./query";

// 민방위 대피시설 API(공공데이터포털)는 위치 검색을 지원하지 않아 전국 데이터(약 2.3만 건)를
// 주기적으로 받아 Firestore에 청크로 저장하고, 조회 시 메모리에서 거리순 정렬한다.
// 명세: https://www.data.go.kr/data/15155067/openapi.do
const shelterApiKey = defineSecret("SHELTER_API_KEY");

const SHELTER_API_URL = "https://apis.data.go.kr/1741000/civil_defense_shelter_info/info";
const PAGE_SIZE = 100; // API 최대값
const CHUNK_SIZE = 2000;
const CHUNK_COLLECTION = "shelterChunks";
// 조회에 쓸 청크 버전을 가리키는 문서. 새 청크를 모두 저장한 뒤에만 전환한다.
const INDEX_DOC = "system/shelterIndex";
const CACHE_TTL_MS = 12 * 60 * 60 * 1000;
const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 20;

/** [id, 이름, 주소, 위도, 경도] — 문서 크기를 줄이기 위한 압축 형태 */
type ShelterRow = [string, string, string, number, number];

/**
 * 포털은 인코딩/디코딩 키를 함께 준다. axios에 맡기면 인코딩 키가 이중 인코딩되므로
 * 인코딩된 형태로 맞춰 URL에 직접 넣는다.
 */
function toEncodedKey(apiKey: string): string {
    const key = apiKey.trim();
    return key.includes("%") ? key : encodeURIComponent(key);
}

function toShelterRow(item: any): ShelterRow | null {
    const lat = Number(item.LAT_EPSG4326);
    const lng = Number(item.LOT_EPST4326); // 명세상 필드명 오타(EPST) 그대로
    const isInKorea = lat > 33 && lat < 39 && lng > 124 && lng < 132;
    const isRemoved = Boolean(item.RMV_YMD?.trim());
    if (!item.FCLT_NM || !isInKorea || isRemoved) return null;

    return [
        String(item.MNG_NO || `${lat},${lng}`),
        String(item.FCLT_NM).trim(),
        String(item.ROAD_NM_WHOL_ADDR || item.LCTN_WHOL_ADDR || "").trim(),
        Number(lat.toFixed(6)),
        Number(lng.toFixed(6)),
    ];
}

async function fetchShelterPage(encodedKey: string, pageNo: number): Promise<any[]> {
    const response = await getWithRetry(`${SHELTER_API_URL}?serviceKey=${encodedKey}`, {
        params: {returnType: "json", pageNo, numOfRows: PAGE_SIZE},
        timeout: 60000,
    });
    const body = response.data?.response?.body;
    if (!body) {
        // 인증키 오류 등은 body 없이 오류 사유만 온다. 빈 페이지로 보면 일부 데이터로
        // 기존 대피소 목록을 덮어쓰게 되므로 동기화를 실패시킨다. (응답에 키는 없다)
        throw new Error(`민방위 대피시설 API 오류 (page ${pageNo}): ${JSON.stringify(response.data).slice(0, 300)}`);
    }
    const item = body.items?.item;
    if (item === undefined) return [];
    // 결과가 1건이면 배열이 아닌 객체로 온다.
    return Array.isArray(item) ? item : [item];
}

async function getWithRetry(url: string, config: object, retries = 2) {
    for (let attempt = 0; ; attempt++) {
        try {
            return await axios.get(url, config);
        } catch (error) {
            if (attempt >= retries) throw error;
            logger.warn(`민방위 대피시설 API 호출 실패, 재시도 (${attempt + 1}/${retries})`);
            await new Promise((resolve) => setTimeout(resolve, 2000));
        }
    }
}

async function fetchAllShelters(encodedKey: string): Promise<ShelterRow[]> {
    const rowsById = new Map<string, ShelterRow>();
    for (let pageNo = 1; ; pageNo++) {
        const items = await fetchShelterPage(encodedKey, pageNo);
        for (const row of items.map(toShelterRow)) {
            if (row) rowsById.set(row[0], row);
        }
        if (pageNo === 1 && items.length > 0 && rowsById.size === 0) {
            logger.warn("민방위 대피시설 응답 항목을 좌표로 변환하지 못함", {sample: items[0]});
        }
        if (items.length < PAGE_SIZE) return [...rowsById.values()];
    }
}

async function saveShelterChunks(db: Firestore, rows: ShelterRow[]): Promise<void> {
    const collection = db.collection(CHUNK_COLLECTION);
    const version = String(Date.now());
    const chunkCount = Math.ceil(rows.length / CHUNK_SIZE);

    for (let i = 0; i < chunkCount; i++) {
        const chunk = rows.slice(i * CHUNK_SIZE, (i + 1) * CHUNK_SIZE);
        // Firestore는 중첩 배열을 허용하지 않아 JSON 문자열로 저장한다.
        await collection.doc(`${version}-${i}`).set({rows: JSON.stringify(chunk)});
    }
    // 동기화가 겹쳐도 더 새로운 버전만 활성화한다.
    const indexRef = db.doc(INDEX_DOC);
    const activeVersion = await db.runTransaction(async (tx) => {
        const current = (await tx.get(indexRef)).data();
        if (current && Number(current.version) > Number(version)) return String(current.version);
        tx.set(indexRef, {version, chunkCount});
        return version;
    });

    // 활성 버전보다 오래된 청크만 지워 동시에 저장 중인 새 버전은 건드리지 않는다.
    const stale = (await collection.listDocuments())
        .filter((doc) => Number(doc.id.split("-")[0]) < Number(activeVersion));
    await Promise.all(stale.map((doc) => doc.delete()));
}

let cachedRows: ShelterRow[] = [];
let cachedAt = 0;

async function loadShelterRows(db: Firestore): Promise<ShelterRow[]> {
    if (cachedRows.length > 0 && Date.now() - cachedAt < CACHE_TTL_MS) return cachedRows;

    const index = (await db.doc(INDEX_DOC).get()).data();
    if (!index) return [];

    const refs = Array.from({length: index.chunkCount}, (_, i) =>
        db.collection(CHUNK_COLLECTION).doc(`${index.version}-${i}`));
    const chunks = await db.getAll(...refs);
    cachedRows = chunks.flatMap((doc) => JSON.parse(doc.data()?.rows ?? "[]") as ShelterRow[]);
    cachedAt = Date.now();
    return cachedRows;
}

function distanceMeters(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const toRad = (deg: number) => (deg * Math.PI) / 180;
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
    return 2 * 6371000 * Math.asin(Math.sqrt(a));
}

export function createShelterFunctions(db: Firestore) {
    const syncShelters = onSchedule(
        {
            schedule: "every monday 04:00",
            timeZone: "Asia/Seoul",
            region: "asia-northeast3",
            timeoutSeconds: 540,
            memory: "512MiB",
            secrets: [shelterApiKey],
        },
        async () => {
            try {
                const rows = await fetchAllShelters(toEncodedKey(shelterApiKey.value()));
                if (rows.length === 0) {
                    logger.warn("민방위 대피시설 데이터가 비어 있어 저장을 건너뜀");
                    return;
                }
                await saveShelterChunks(db, rows);
                logger.info(`민방위 대피시설 ${rows.length}건 동기화 완료`);
            } catch (error) {
                logger.error("민방위 대피시설 동기화 실패, 기존 데이터 유지", safeErrorSummary(error));
                throw new Error("민방위 대피시설 동기화 실패");
            }
        }
    );

    const nearbyShelters = onRequest(
        {region: "asia-northeast3", memory: "512MiB"},
        async (req, res) => {
            const lat = toNumber(req.query.lat);
            const lng = toNumber(req.query.lng);
            const requested = Number(req.query.limit);
            const limit = Number.isInteger(requested) && requested > 0 ?
                Math.min(requested, MAX_LIMIT) : DEFAULT_LIMIT;
            if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
                res.status(400).json({error: "lat, lng가 필요합니다."});
                return;
            }

            try {
                const shelters = (await loadShelterRows(db))
                    .map(([id, name, address, sLat, sLng]) => ({
                        id, name, address, lat: sLat, lng: sLng,
                        distanceMeters: Math.round(distanceMeters(lat, lng, sLat, sLng)),
                    }))
                    .sort((a, b) => a.distanceMeters - b.distanceMeters)
                    .slice(0, limit);

                res.status(200).json({shelters});
            } catch (error) {
                logger.error("대피소 조회 실패", safeErrorSummary(error));
                res.status(500).json({error: "대피소 조회 실패"});
            }
        }
    );

    return {syncShelters, nearbyShelters};
}
