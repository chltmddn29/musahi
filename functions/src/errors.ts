import axios from "axios";

/**
 * 로그용 오류 요약. axios 오류 객체에는 요청 헤더·URL(API 키 포함)이 담겨 있어
 * 그대로 기록하지 않고 메시지와 상태 코드만 남긴다.
 */
export function safeErrorSummary(error: unknown): {message: string; status?: number} {
    if (axios.isAxiosError(error)) {
        return {message: error.message, status: error.response?.status};
    }
    return {message: error instanceof Error ? error.message : String(error)};
}
