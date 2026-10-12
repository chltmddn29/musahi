const {test} = require("node:test");
const assert = require("node:assert/strict");
const {simplifyRoute} = require("../lib/walking_route");

const line = {geometry: {type: "LineString", coordinates: [[127.0, 37.0], [127.1, 37.1]]}, properties: {totalDistance: 300, totalTime: 240}};
const point = (properties) => ({geometry: {type: "Point"}, properties});

test("경로를 [lat, lng] 순서로 바꾸고 요약을 읽는다", () => {
    const route = simplifyRoute([line]);
    assert.deepEqual(route.path, [[37.0, 127.0], [37.1, 127.1]]);
    assert.equal(route.totalDistance, 300);
    assert.equal(route.totalTime, 240);
});

test("출발·도착 지점은 안내에서 뺀다", () => {
    const route = simplifyRoute([line, point({turnType: 200, description: "출발"}), point({turnType: 12, description: "좌회전"})]);
    assert.deepEqual(route.steps, [{direction: "left", description: "좌회전"}]);
});

test("안내 문구가 없는 지점은 빈 문자열로 내려 앱 파싱이 실패하지 않게 한다", () => {
    const route = simplifyRoute([line, point({turnType: 13})]);
    assert.deepEqual(route.steps, [{direction: "right", description: ""}]);
    assert.ok("description" in JSON.parse(JSON.stringify(route.steps[0])));
});
