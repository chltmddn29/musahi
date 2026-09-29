const {test} = require("node:test");
const assert = require("node:assert/strict");
const {AxiosError} = require("axios");
const {toNumber} = require("../lib/query");
const {safeErrorSummary} = require("../lib/errors");

test("toNumber: 빈 값은 0이 아니라 NaN", () => {
    assert.ok(Number.isNaN(toNumber("")));
    assert.ok(Number.isNaN(toNumber("  ")));
    assert.ok(Number.isNaN(toNumber(undefined)));
    assert.ok(Number.isNaN(toNumber(["1"])));
    assert.equal(toNumber("35.16"), 35.16);
    assert.equal(toNumber("0"), 0);
});

test("safeErrorSummary: axios 오류에서 요청 설정(키)을 빼고 메시지·상태만 남긴다", () => {
    const error = new AxiosError(
        "Request failed with status code 401",
        "ERR_BAD_REQUEST",
        {url: "https://api.example?serviceKey=SECRET", headers: {appKey: "SECRET"}},
        null,
        {status: 401, data: {}, headers: {}, config: {}, statusText: ""},
    );
    const summary = safeErrorSummary(error);
    assert.deepEqual(summary, {message: "Request failed with status code 401", status: 401});
    assert.ok(!JSON.stringify(summary).includes("SECRET"));
});

test("safeErrorSummary: 일반 오류와 문자열도 메시지로 남긴다", () => {
    assert.deepEqual(safeErrorSummary(new Error("boom")), {message: "boom"});
    assert.deepEqual(safeErrorSummary("oops"), {message: "oops"});
});
