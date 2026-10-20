// 재난문자 폴링의 순수 로직. Firebase·외부 API와 분리해 단위 테스트할 수 있게 한다.

const KST_OFFSET_MS = 9 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
// 폴링 주기(5분)보다 길게 잡아, 자정 직전 마지막 폴링 이후의 문자를 새 날짜 조회에서도 가져온다.
const PREVIOUS_DAY_GRACE_MS = 10 * 60 * 1000;

function toYYYYMMDD(kstMs: number): string {
    const kst = new Date(kstMs);
    const yyyy = kst.getUTCFullYear();
    const mm = String(kst.getUTCMonth() + 1).padStart(2, "0");
    const dd = String(kst.getUTCDate()).padStart(2, "0");
    return `${yyyy}${mm}${dd}`;
}

/**
 * 조회할 생성일(KST) 목록. 자정 직후에는 전날도 함께 조회한다.
 * 이미 처리한 문자는 SN으로 걸러지므로 겹쳐 조회해도 중복 발송되지 않는다.
 */
export function getQueryDates(now: Date = new Date()): string[] {
    const kstMs = now.getTime() + KST_OFFSET_MS;
    const dates = [toYYYYMMDD(kstMs)];
    if (kstMs % DAY_MS < PREVIOUS_DAY_GRACE_MS) dates.push(toYYYYMMDD(kstMs - DAY_MS));
    return dates;
}

/**
 * [lastSn]보다 큰 문자를 SN 오름차순으로 [handle]에 넘기고, 끝까지 처리한 마지막 SN을 돌려준다.
 * 처리가 실패하면 거기서 멈춘다. 그래서 반환값 이하의 문자는 모두 처리된 것이고,
 * 실패한 문자는 다음 폴링에서 다시 시도한다. 단, [shouldGiveUp]이 true인 문자는 건너뛴다.
 */
export async function processNewMessages(
    messages: {SN: number}[],
    lastSn: number,
    handle: (msg: any) => Promise<void>,
    onError: (msg: any, error: unknown) => void,
    shouldGiveUp: (msg: any) => boolean = () => false,
): Promise<number> {
    const pending = messages
        .filter((msg) => msg.SN > lastSn)
        .sort((a, b) => a.SN - b.SN);

    let processedSn = lastSn;
    for (const msg of pending) {
        try {
            await handle(msg);
        } catch (error) {
            onError(msg, error);
            // 계속 실패하는 문자 하나가 뒤의 모든 문자를 막지 않도록, 너무 오래된 문자는 포기하고 넘어간다.
            if (!shouldGiveUp(msg)) break;
        }
        processedSn = msg.SN;
    }
    return processedSn;
}

const GIVE_UP_AFTER_MS = 60 * 60 * 1000;

/** 생성 시각("YYYY/MM/DD HH:mm:ss", KST)이 1시간 넘게 지났으면 재시도를 포기한다. 시각을 읽지 못하면 포기하지 않는다. */
export function isStaleMessage(crtDt: unknown, now: Date = new Date()): boolean {
    const match = /^(\d{4})[/-](\d{2})[/-](\d{2})[ T](\d{2}):(\d{2}):(\d{2})/.exec(String(crtDt ?? ""));
    if (!match) return false;
    const [, y, mo, d, h, mi, sec] = match;
    const createdMs = Date.parse(`${y}-${mo}-${d}T${h}:${mi}:${sec}+09:00`);
    return Number.isFinite(createdMs) && now.getTime() - createdMs > GIVE_UP_AFTER_MS;
}

/**
 * 모든 토픽에 보내되, 실패한 토픽만 [attempts]번까지 다시 보낸다. 끝내 실패한 토픽이 있으면 던진다.
 * 이미 성공한 토픽에 다시 보내 알림이 중복되는 것을 막는다.
 */
export async function sendToAllTopics(
    topics: string[],
    send: (topic: string) => Promise<unknown>,
    attempts = 3,
): Promise<void> {
    let pending = topics;
    let lastError: unknown;
    for (let attempt = 0; attempt < attempts && pending.length > 0; attempt++) {
        const results = await Promise.allSettled(pending.map(send));
        const failed: string[] = [];
        results.forEach((result, i) => {
            if (result.status === "rejected") {
                failed.push(pending[i]);
                lastError = result.reason;
            }
        });
        pending = failed;
    }
    if (pending.length > 0) throw lastError;
}
