import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";
import {Firestore} from "firebase-admin/firestore";

// 민방위 대피시설 API(공공데이터포털)는 위치 검색을 지원하지 않아 전국 데이터(약 2.3만 건)를
// 주기적으로 받아 Firestore에 청크로 저장하고, 조회 시 메모리에서 거리순 정렬한다.
// 명세: https://www.data.go.kr/data/15155067/openapi.do
const shelterApiKey = defineSecret("SHELTER_API_KEY");

const SHELTER_API_URL = "https://apis.data.go.kr/1741000/civil_defense_shelter_info/info";
const PAGE_SIZE = 100; // API 최대값
const CHUNK_SIZE = 2000;
const CHUNK_COLLECTION = "shelterChunks";
const CACHE_TTL_MS = 12 * 60 * 60 * 1000;
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
    const item = response.data?.response?.body?.items?.item;
    if (item === undefined) {
        // 인증키 오류 등은 items 없이 header에 사유가 담겨 온다.
        logger.warn("민방위 대피시설 API 응답에 items가 없음", {
            pageNo,
            status: response.status,
            header: response.data?.response?.header,
            preview: JSON.stringify(response.data).slice(0, 500),
        });
        return [];
    }
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
    const chunkCount = Math.ceil(rows.length / CHUNK_SIZE);

    for (let i = 0; i < chunkCount; i++) {
        const chunk = rows.slice(i * CHUNK_SIZE, (i + 1) * CHUNK_SIZE);
        // Firestore는 중첩 배열을 허용하지 않아 JSON 문자열로 저장한다.
        await collection.doc(String(i)).set({rows: JSON.stringify(chunk)});
    }

    const existing = await collection.listDocuments();
    await Promise.all(
        existing.filter((doc) => Number(doc.id) >= chunkCount).map((doc) => doc.delete())
    );
}

let cachedRows: ShelterRow[] = [];
let cachedAt = 0;

async function loadShelterRows(db: Firestore): Promise<ShelterRow[]> {
    if (cachedRows.length > 0 && Date.now() - cachedAt < CACHE_TTL_MS) return cachedRows;

    const snapshot = await db.collection(CHUNK_COLLECTION).get();
    cachedRows = snapshot.docs.flatMap((doc) => JSON.parse(doc.data().rows) as ShelterRow[]);
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
            const rows = await fetchAllShelters(toEncodedKey(shelterApiKey.value()));
            if (rows.length === 0) {
                logger.warn("민방위 대피시설 데이터가 비어 있어 저장을 건너뜀");
                return;
            }
            await saveShelterChunks(db, rows);
            logger.info(`민방위 대피시설 ${rows.length}건 동기화 완료`);
        }
    );

    const nearbyShelters = onRequest(
        {region: "asia-northeast3", memory: "512MiB"},
        async (req, res) => {
            const lat = Number(req.query.lat);
            const lng = Number(req.query.lng);
            const limit = Math.min(Number(req.query.limit) || 10, MAX_LIMIT);
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
                logger.error("대피소 조회 실패", {error});
                res.status(500).json({error: "대피소 조회 실패"});
            }
        }
    );

    return {syncShelters, nearbyShelters};
}
