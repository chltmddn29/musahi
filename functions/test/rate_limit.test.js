const {test} = require("node:test");
const assert = require("node:assert/strict");
const {createRateLimiter} = require("../lib/rate_limit");

test("윈도우 안에서 최대 횟수를 넘으면 제한한다", () => {
    const limiter = createRateLimiter(1000, 2);
    assert.equal(limiter.isLimited("a", 0), false);
    assert.equal(limiter.isLimited("a", 100), false);
    assert.equal(limiter.isLimited("a", 200), true);
    assert.equal(limiter.isLimited("b", 200), false);
});

test("윈도우가 지나면 다시 허용한다", () => {
    const limiter = createRateLimiter(1000, 1);
    assert.equal(limiter.isLimited("a", 0), false);
    assert.equal(limiter.isLimited("a", 500), true);
    assert.equal(limiter.isLimited("a", 1500), false);
});

test("다시 오지 않는 클라이언트 항목은 쌓이지 않고 정리된다", () => {
    const limiter = createRateLimiter(1000, 5, 10);
    // 각 클라이언트는 한 번만 오고, 다음 요청 시점에는 이미 윈도우가 지나 있다.
    for (let i = 0; i < 100; i++) limiter.isLimited(`ip-${i}`, i * 2000);
    assert.ok(limiter.size <= 11, `size=${limiter.size}`);
});

test("윈도우 안에 서로 다른 클라이언트가 몰려도 추적 수가 상한을 넘지 않는다", () => {
    const limiter = createRateLimiter(1000, 5, 10);
    for (let i = 0; i < 5000; i++) limiter.isLimited(`ip-${i}`, i % 500);
    assert.ok(limiter.size <= 10, `size=${limiter.size}`);
});

test("상한에서도 최근 활동한 클라이언트의 제한 기록은 유지한다", () => {
    const limiter = createRateLimiter(1000, 1, 2);
    for (let i = 0; i < 5; i++) limiter.isLimited(`ip-${i}`, 0);
    assert.equal(limiter.isLimited("ip-4", 500), true);
    assert.equal(limiter.isLimited("ip-3", 500), true);
});

test("활성 클라이언트가 많아도 정리는 윈도우당 한 번만 한다", () => {
    const limiter = createRateLimiter(1000, 100, 3);
    for (let i = 0; i < 20; i++) limiter.isLimited(`ip-${i}`, 10);
    assert.equal(limiter.size, 3);
    // 같은 윈도우 안의 새 요청도 상한을 지킨다.
    for (let i = 20; i < 40; i++) limiter.isLimited(`ip-${i}`, 20);
    assert.equal(limiter.size, 3);
});
