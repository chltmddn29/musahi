/**
 * 클라이언트별 슬라이딩 윈도우 rate limit. 인스턴스별 최소한의 제한이다.
 * 분산 환경에서 완전한 보장은 아니지만, 단일 호출자가 외부 API quota와 함수 비용을
 * 소진시키는 것을 완화한다. 다시 오지 않는 클라이언트 항목이 쌓이지 않도록
 * 항목 수가 [maxClients]를 넘으면 만료된 항목을 정리한다.
 */
export function createRateLimiter(windowMs: number, maxRequests: number, maxClients = 1000) {
    const timestampsByClient = new Map<string, number[]>();

    return {
        isLimited(clientId: string, now = Date.now()): boolean {
            const windowStart = now - windowMs;
            if (timestampsByClient.size > maxClients) {
                for (const [id, list] of timestampsByClient) {
                    if (list.length === 0 || list[list.length - 1] <= windowStart) {
                        timestampsByClient.delete(id);
                    }
                }
            }
            const timestamps = (timestampsByClient.get(clientId) ?? []).filter((ts) => ts > windowStart);
            const limited = timestamps.length >= maxRequests;
            if (!limited) timestamps.push(now);
            timestampsByClient.set(clientId, timestamps);
            return limited;
        },
        get size() {
            return timestampsByClient.size;
        },
    };
}
