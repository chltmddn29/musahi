const {test} = require("node:test");
const assert = require("node:assert/strict");
const {
    toEncodedKey, toShelterRow, distanceMeters, searchShelters, areaOf, staleChunkIds,
} = require("../lib/shelter_logic");
const {parseRegions} = require("../lib/region_match");

// [id, 이름, 주소, 위도, 경도]
const HAEUNDAE_1 = ["h1", "롯데캐슬", "부산광역시 해운대구 중동2로34번길 15", 35.165165, 129.163916];
const HAEUNDAE_2 = ["h2", "해운대역", "부산광역시 해운대구 해운대로 지하 626", 35.163776, 129.159216];
const SEOUL_1 = ["s1", "서울시청", "서울특별시 중구 세종대로 110", 37.5663, 126.9779];
const SEOUL_2 = ["s2", "을지로입구역", "서울특별시 중구 을지로 지하 42", 37.5660, 126.9822];
const ROWS = [HAEUNDAE_1, HAEUNDAE_2, SEOUL_1, SEOUL_2];
const USER_IN_HAEUNDAE = {lat: 35.1631, lng: 129.1636};

test("toEncodedKey: 디코딩 키는 인코딩하고 인코딩 키는 그대로 둔다", () => {
    assert.equal(toEncodedKey(" ab+c/d= "), "ab%2Bc%2Fd%3D");
    assert.equal(toEncodedKey("ab%2Bc%2Fd%3D"), "ab%2Bc%2Fd%3D");
});

test("toShelterRow: 명세 필드를 압축 행으로 바꾼다", () => {
    const row = toShelterRow({
        MNG_NO: "3330000-S1", FCLT_NM: " 롯데캐슬 ", ROAD_NM_WHOL_ADDR: "부산광역시 해운대구 중동",
        LAT_EPSG4326: "35.1651651", LOT_EPST4326: "129.1639161",
    });
    assert.deepEqual(row, ["3330000-S1", "롯데캐슬", "부산광역시 해운대구 중동", 35.165165, 129.163916]);
});

test("toShelterRow: 도로명주소가 없으면 지번주소를 쓴다", () => {
    const row = toShelterRow({
        FCLT_NM: "시설", LCTN_WHOL_ADDR: "지번주소", LAT_EPSG4326: "35", LOT_EPST4326: "129",
    });
    assert.equal(row[2], "지번주소");
});

test("toShelterRow: 해제된 시설·국외 좌표·이름 없는 항목은 버린다", () => {
    const base = {FCLT_NM: "시설", LAT_EPSG4326: "35", LOT_EPST4326: "129"};
    assert.equal(toShelterRow({...base, RMV_YMD: "20200101"}), null);
    assert.equal(toShelterRow({...base, LAT_EPSG4326: "0", LOT_EPST4326: "0"}), null);
    assert.equal(toShelterRow({...base, FCLT_NM: ""}), null);
    assert.notEqual(toShelterRow({...base, RMV_YMD: " "}), null);
});

test("distanceMeters: 위도 1도는 약 111.2km, 같은 점은 0", () => {
    const d = distanceMeters(35, 129, 36, 129);
    assert.ok(Math.abs(d - 111_195) < 10, `${d}`);
    assert.equal(distanceMeters(35, 129, 35, 129), 0);
});

test("searchShelters: 지역이 없으면 내 주변을 가까운 순으로 반환한다", () => {
    const result = searchShelters(ROWS, USER_IN_HAEUNDAE, [], 2);
    assert.equal(result.mode, "nearby");
    assert.deepEqual(result.shelters.map((s) => s.id), ["h1", "h2"]);
    assert.ok(result.shelters[0].distanceMeters <= result.shelters[1].distanceMeters);
});

test("searchShelters: 내가 재난 지역 안이면 내 주변 대피소", () => {
    const result = searchShelters(ROWS, USER_IN_HAEUNDAE, parseRegions("부산광역시 해운대구"), 5);
    assert.equal(result.mode, "nearby");
    assert.equal(result.center, undefined);
});

test("searchShelters: 내가 재난 지역 밖이면 지역 안 대피소만, 내 위치 기준 가까운 순", () => {
    const result = searchShelters(ROWS, USER_IN_HAEUNDAE, parseRegions("서울특별시 중구"), 5);
    assert.equal(result.mode, "region");
    assert.deepEqual(new Set(result.shelters.map((s) => s.id)), new Set(["s1", "s2"]));
    const distances = result.shelters.map((s) => s.distanceMeters);
    assert.deepEqual(distances, [...distances].sort((a, b) => a - b));
    assert.ok(Math.abs(result.center.lat - 37.56615) < 1e-6);
});

test("searchShelters: 매칭되는 대피소가 없는 지역이면 내 주변으로 대체한다", () => {
    const result = searchShelters(ROWS, USER_IN_HAEUNDAE, parseRegions("없는도 없는시"), 5);
    assert.equal(result.mode, "nearby");
});

test("searchShelters: limit만큼만 반환한다", () => {
    assert.equal(searchShelters(ROWS, USER_IN_HAEUNDAE, [], 3).shelters.length, 3);
});

test("areaOf: 지역 대피소의 중심과 반경을 계산한다", () => {
    const [region] = parseRegions("부산광역시 해운대구");
    const area = areaOf(region, ROWS);
    assert.equal(area.name, "부산광역시 해운대구");
    assert.ok(Math.abs(area.center.lat - (35.165165 + 35.163776) / 2) < 1e-9);
    assert.ok(area.radiusMeters > 0 && area.radiusMeters < 1_000, `${area.radiusMeters}`);
});

test("areaOf: 반경은 외곽 10%를 제외해 섬 하나로 원이 커지지 않는다", () => {
    const inland = Array.from({length: 9}, (_, i) =>
        [`c${i}`, "시설", "인천광역시 남동구 정각로 29", 37.4563 + i * 0.001, 126.7052]);
    const island = ["far", "백령도", "인천광역시 옹진군 백령면", 37.97, 124.7];
    const [region] = parseRegions("인천광역시 전체");
    const area = areaOf(region, [...inland, island]);
    assert.ok(area.radiusMeters < 200_000, `${area.radiusMeters}`);
});

test("areaOf: 매칭되는 대피소가 없으면 null", () => {
    const [region] = parseRegions("없는도 없는시");
    assert.equal(areaOf(region, ROWS), null);
});

test("searchShelters: 사용자 행정구역 주소가 있으면 그것으로 지역 안팎을 판단한다", () => {
    // 가장 가까운 대피소는 해운대구지만, 사용자는 경계 너머 수영구에 있는 경우
    const regions = parseRegions("부산광역시 해운대구");
    const outside = searchShelters(ROWS, USER_IN_HAEUNDAE, regions, 5, "부산광역시 수영구 광안1동");
    assert.equal(outside.mode, "region");
    const inside = searchShelters(ROWS, USER_IN_HAEUNDAE, regions, 5, "부산광역시 해운대구 중1동");
    assert.equal(inside.mode, "nearby");
});

test("searchShelters: 주소 조회에 실패하면 가장 가까운 대피소 주소로 대신 판단한다", () => {
    const result = searchShelters(ROWS, USER_IN_HAEUNDAE, parseRegions("부산광역시 해운대구"), 5, undefined);
    assert.equal(result.mode, "nearby");
});

test("staleChunkIds: 직전 버전과 그 이후는 남기고 더 오래된 청크만 고른다", () => {
    const ids = ["0", "1", "100-0", "100-1", "200-0", "300-0", "300-1"];
    assert.deepEqual(staleChunkIds(ids, "200"), ["0", "1", "100-0", "100-1"]);
});

test("staleChunkIds: 첫 동기화(직전 버전 = 새 버전)면 옛 형식 청크만 지운다", () => {
    assert.deepEqual(staleChunkIds(["0", "1", "500-0"], "500"), ["0", "1"]);
});

