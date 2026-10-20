const {test} = require("node:test");
const assert = require("node:assert/strict");
const {getQueryDates, isStaleMessage, processNewMessages, sendToAllTopics} = require("../lib/disaster_poll");

// KST = UTC+9
const kst = (iso) => new Date(`${iso}+09:00`);

test("getQueryDates: 낮에는 오늘만 조회한다", () => {
    assert.deepEqual(getQueryDates(kst("2026-10-13T12:00:00")), ["20261013"]);
});

test("getQueryDates: 자정 직후 10분 동안은 전날도 조회한다", () => {
    assert.deepEqual(getQueryDates(kst("2026-10-13T00:00:00")), ["20261013", "20261012"]);
    assert.deepEqual(getQueryDates(kst("2026-10-13T00:09:59")), ["20261013", "20261012"]);
    assert.deepEqual(getQueryDates(kst("2026-10-13T00:10:00")), ["20261013"]);
});

test("getQueryDates: 월초 자정에는 지난달 말일을 조회한다", () => {
    assert.deepEqual(getQueryDates(kst("2026-11-01T00:02:00")), ["20261101", "20261031"]);
});

test("processNewMessages: 새 문자만 SN 오름차순으로 처리한다", async () => {
    const handled = [];
    const processedSn = await processNewMessages(
        [{SN: 5}, {SN: 3}, {SN: 4}, {SN: 1}], 3,
        async (msg) => { handled.push(msg.SN); },
        () => assert.fail("오류 없음"),
    );
    assert.deepEqual(handled, [4, 5]);
    assert.equal(processedSn, 5);
});

test("processNewMessages: 새 문자가 없으면 lastSn을 그대로 돌려준다", async () => {
    const processedSn = await processNewMessages([{SN: 1}], 9, async () => {}, () => {});
    assert.equal(processedSn, 9);
});

test("processNewMessages: 실패하면 거기서 멈추고 그 앞까지만 처리한 것으로 본다", async () => {
    const handled = [];
    const errors = [];
    const processedSn = await processNewMessages(
        [{SN: 1}, {SN: 2}, {SN: 3}], 0,
        async (msg) => {
            if (msg.SN === 2) throw new Error("FCM 실패");
            handled.push(msg.SN);
        },
        (msg, error) => errors.push([msg.SN, error.message]),
    );
    assert.deepEqual(handled, [1]);
    assert.deepEqual(errors, [[2, "FCM 실패"]]);
    assert.equal(processedSn, 1, "실패한 2번은 다음 폴링에서 다시 시도해야 한다");
});

test("processNewMessages: 포기 대상으로 판정된 문자는 건너뛰고 뒤 문자를 계속 처리한다", async () => {
    const handled = [];
    const processedSn = await processNewMessages(
        [{SN: 1}, {SN: 2}, {SN: 3}], 0,
        async (msg) => {
            if (msg.SN === 2) throw new Error("계속 실패");
            handled.push(msg.SN);
        },
        () => {},
        (msg) => msg.SN === 2,
    );
    assert.deepEqual(handled, [1, 3]);
    assert.equal(processedSn, 3);
});

test("isStaleMessage: 1시간이 지난 문자만 오래된 것으로 본다", () => {
    const now = kst("2026-10-13T12:00:00");
    assert.equal(isStaleMessage("2026/10/13 10:59:00", now), true);
    assert.equal(isStaleMessage("2026/10/13 11:30:00", now), false);
    assert.equal(isStaleMessage("알 수 없는 형식", now), false);
    assert.equal(isStaleMessage(undefined, now), false);
});

test("sendToAllTopics: 실패한 토픽만 다시 보낸다", async () => {
    const sent = [];
    let failOnce = true;
    await sendToAllTopics(["a", "b"], async (topic) => {
        if (topic === "b" && failOnce) {
            failOnce = false;
            throw new Error("일시 오류");
        }
        sent.push(topic);
    });
    assert.deepEqual(sent, ["a", "b"], "a는 한 번만 보내야 한다");
});

test("sendToAllTopics: 끝내 실패하는 토픽이 있으면 던진다", async () => {
    await assert.rejects(
        sendToAllTopics(["a", "b"], async (topic) => {
            if (topic === "b") throw new Error("계속 실패");
        }, 2),
        /계속 실패/,
    );
});
