/**
 * 클라이언트별 슬라이딩 윈도우 rate limit. 인스턴스별 최소한의 제한이다.
 * 분산 환경에서 완전한 보장은 아니지만, 단일 호출자가 외부 API quota와 함수 비용을
 * 소진시키는 것을 완화한다.
 *
 * 추적하는 클라이언트는 최대 [maxClients]개다. 넘으면 만료된 항목을 정리하고(윈도우당
 * 한 번), 그래도 넘으면 가장 오래 활동이 없던 클라이언트부터 내보낸다. 그래서 서로 다른
 * IP가 몰려도 메모리와 요청당 비용이 일정하다. 내보낸 클라이언트는 제한 기록이 초기화된다.
 */
export function createRateLimiter(windowMs: number, maxRequests: number, maxClients = 1000) {
    // Map은 삽입 순서를 유지한다. 요청마다 항목을 맨 뒤로 옮겨 앞쪽이 가장 오래된 클라이언트가 되게 한다.
    const timestampsByClient = new Map<string, number[]>();
    let lastSweepAt = -Infinity;

    return {
        isLimited(clientId: string, now = Date.now()): boolean {
            const windowStart = now - windowMs;
            if (timestampsByClient.size > maxClients && now - lastSweepAt >= windowMs) {
                lastSweepAt = now;
                for (const [id, list] of timestampsByClient) {
                    if (list.length === 0 || list[list.length - 1] <= windowStart) {
                        timestampsByClient.delete(id);
                    }
                }
            }
            const timestamps = (timestampsByClient.get(clientId) ?? []).filter((ts) => ts > windowStart);
            const limited = timestamps.length >= maxRequests;
            if (!limited) timestamps.push(now);
            timestampsByClient.delete(clientId);
            timestampsByClient.set(clientId, timestamps);
            while (timestampsByClient.size > maxClients) {
                const [oldest] = timestampsByClient.keys();
                timestampsByClient.delete(oldest);
            }
            return limited;
        },
        get size() {
            return timestampsByClient.size;
        },
    };
}
