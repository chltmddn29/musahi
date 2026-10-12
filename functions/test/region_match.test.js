const {test} = require("node:test");
const assert = require("node:assert/strict");
const {parseRegions, isInRegions} = require("../lib/region_match");

const inRegion = (region, address) => isInRegions(address, parseRegions(region));

test("시군구가 같으면 지역 안으로 본다", () => {
    assert.equal(inRegion("부산광역시 해운대구", "부산광역시 해운대구 중동2로34번길 15"), true);
    assert.equal(inRegion("부산광역시 해운대구", "부산광역시 수영구 광안해변로 1"), false);
});

test("'전체'는 시도 전체와 매칭한다", () => {
    assert.equal(inRegion("서울특별시 전체", "서울특별시 중구 세종대로 110"), true);
    assert.equal(inRegion("경상북도 포항시 전체", "경상북도 포항시 남구 시청로 1"), true);
});

test("시도 표기가 달라도 같은 지역으로 본다", () => {
    assert.equal(inRegion("강원도 강릉시", "강원특별자치도 강릉시 강릉대로 33"), true);
    assert.equal(inRegion("광주광역시 서구", "전남광주통합특별시 서구 내방로 111"), true);
    assert.equal(inRegion("전라북도 전주시 완산구", "전북특별자치도 전주시 완산구 노송광장로 10"), true);
});

test("하위 구가 다르면 지역 밖으로 본다", () => {
    assert.equal(inRegion("경상북도 포항시 북구", "경상북도 포항시 남구 시청로 1"), false);
});

test("이름이 앞부분만 겹치는 도로명은 구로 오인하지 않는다", () => {
    assert.equal(inRegion("대구광역시 중구", "대구광역시 중구청로 1"), false);
});

test("여러 지역 중 하나라도 맞으면 지역 안이다", () => {
    assert.equal(inRegion("부산광역시 해운대구,서울특별시 전체", "서울특별시 강남구 테헤란로 1"), true);
});

test("parseRegions는 빈 값과 공백을 걸러내고 원래 이름을 보존한다", () => {
    assert.deepEqual(parseRegions(undefined), []);
    assert.deepEqual(parseRegions(" , "), []);
    assert.deepEqual(
        parseRegions(" 부산광역시 해운대구 ,서울특별시 전체").map((r) => r.name),
        ["부산광역시 해운대구", "서울특별시 전체"],
    );
});
