const {test, beforeEach, mock} = require("node:test");
const assert = require("node:assert/strict");
const axios = require("axios");

process.env.SGIS_CONSUMER_KEY = "test-key";
process.env.SGIS_CONSUMER_SECRET = "test-secret";
const {reverseGeocode, resetSgisAccessToken, isSgisAuthError} = require("../lib/sgis");

const ok = (result) => ({data: {errCd: 0, result}});
const AUTH_OK = ok({accessToken: "token"});
const COORD_OK = ok({posX: 1_000_000, posY: 1_800_000});
const PLACE_OK = ok([{full_addr: "부산광역시 해운대구 중1동"}]);
const TOKEN_REJECTED = {data: {errCd: -401, errMsg: "인증 정보가 존재하지 않습니다"}};

/** 경로별 응답을 순서대로 돌려주는 가짜 axios.get. 인증 호출 횟수를 센다. */
function fakeSgis(responses) {
    const calls = {auth: 0};
    mock.method(axios, "get", async (url) => {
        const key = ["authentication", "transcoord", "rgeocode"].find((k) => url.includes(k));
        if (key === "authentication") calls.auth++;
        const next = responses[key].shift();
        if (next instanceof Error) throw next;
        return next;
    });
    return calls;
}

beforeEach(() => {
    mock.restoreAll();
    resetSgisAccessToken();
});

test("isSgisAuthError: -401만 인증 오류로 본다", () => {
    assert.equal(isSgisAuthError(-401), true);
    assert.equal(isSgisAuthError(-100), false);
    assert.equal(isSgisAuthError(0), false);
});

test("reverseGeocode: 행정구역 주소를 돌려준다", async () => {
    fakeSgis({authentication: [AUTH_OK], transcoord: [COORD_OK], rgeocode: [PLACE_OK]});
    assert.equal(await reverseGeocode(35.16, 129.16), "부산광역시 해운대구 중1동");
});

test("reverseGeocode: full_addr가 없으면 시도·시군구·읍면동을 잇는다", async () => {
    fakeSgis({
        authentication: [AUTH_OK],
        transcoord: [COORD_OK],
        rgeocode: [ok([{sido_nm: "부산광역시", sgg_nm: "수영구", emdong_nm: "광안2동"}])],
    });
    assert.equal(await reverseGeocode(35.15, 129.11), "부산광역시 수영구 광안2동");
});

test("시간 초과 등 네트워크 오류로는 토큰을 버리지 않는다", async () => {
    const calls = fakeSgis({
        authentication: [AUTH_OK, AUTH_OK],
        transcoord: [new axios.AxiosError("timeout of 10000ms exceeded", "ECONNABORTED"), COORD_OK],
        rgeocode: [PLACE_OK],
    });
    await assert.rejects(reverseGeocode(35.16, 129.16), /timeout/);
    await reverseGeocode(35.16, 129.16);
    assert.equal(calls.auth, 1, "토큰을 재사용해야 한다");
});

test("토큰 만료(-401)면 토큰을 버리고 다음 요청에 다시 인증한다", async () => {
    const calls = fakeSgis({
        authentication: [AUTH_OK, AUTH_OK],
        transcoord: [TOKEN_REJECTED, COORD_OK],
        rgeocode: [PLACE_OK],
    });
    await assert.rejects(reverseGeocode(35.16, 129.16), /transcoord/);
    await reverseGeocode(35.16, 129.16);
    assert.equal(calls.auth, 2, "다시 인증해야 한다");
});
