/** 쿼리 값을 숫자로 변환한다. 빈 문자열이 0으로 바뀌지 않도록 값이 없으면 NaN. */
export function toNumber(value: unknown): number {
    return typeof value === "string" && value.trim() !== "" ? Number(value) : NaN;
}
