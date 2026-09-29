import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";
import {Firestore} from "firebase-admin/firestore";
import {safeErrorSummary} from "./errors";
import {toNumber} from "./query";
import {parseRegions} from "./region_match";
import {ShelterRow, areaOf, searchShelters, toEncodedKey, toShelterRow} from "./shelter_logic";

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
                const rows = await loadShelterRows(db);
                const regions = parseRegions(req.query.regions);
                res.status(200).json(searchShelters(rows, {lat, lng}, regions, limit));
            } catch (error) {
                logger.error("대피소 조회 실패", safeErrorSummary(error));
                res.status(500).json({error: "대피소 조회 실패"});
            }
        }
    );

    // 재난문자 상세 지도용. 재난문자에는 좌표가 없어 지역 내 대피소 분포로 중심·범위를 추정한다.
    const disasterAreas = onRequest(
        {region: "asia-northeast3", memory: "512MiB"},
        async (req, res) => {
            try {
                const rows = await loadShelterRows(db);
                const areas = parseRegions(req.query.regions)
                    .map((region) => areaOf(region, rows))
                    .filter((area) => area !== null);
                res.status(200).json({areas});
            } catch (error) {
                logger.error("재난 지역 조회 실패", safeErrorSummary(error));
                res.status(500).json({error: "재난 지역 조회 실패"});
            }
        }
    );

    return {syncShelters, nearbyShelters, disasterAreas};
}
