// 재난문자 수신지역명("부산광역시 해운대구", "서울특별시 전체")과 대피소 주소를 비교한다.
// 두 데이터의 시도 표기가 다를 수 있어(강원도/강원특별자치도, 광주광역시/전남광주통합특별시 등)
// 시도는 공통 키로 맞춘 뒤 비교한다.

export interface RegionFilter {
    /** 원래 지역명 ("부산광역시 해운대구") */
    name: string;
    sido: string;
    /** 시군구 이하 경로. 빈 문자열이면 시도 전체. */
    rest: string;
}

// 광주·전남은 통합특별시 표기("전남광주통합특별시")에서 시도만으로는 구분되지 않아
// 하위 첫 토큰으로 가른다. 광주는 구로 시작하고(서구, 북구) 전남은 시·군이다.
const MERGED_GWANGJU_JEONNAM = "전남광주";

const SIDO_ALIASES: [RegExp, string][] = [
    [/^전남광주/, MERGED_GWANGJU_JEONNAM],
    [/^광주/, "광주"],
    [/^(전라남도|전남)/, "전남"],
    [/^(전라북도|전북)/, "전북"],
    [/^(충청북도|충북)/, "충북"],
    [/^(충청남도|충남)/, "충남"],
    [/^(경상북도|경북)/, "경북"],
    [/^(경상남도|경남)/, "경남"],
];

function normalizeSido(token: string): string {
    const alias = SIDO_ALIASES.find(([pattern]) => pattern.test(token));
    return alias ? alias[1] : token.slice(0, 2);
}

function splitSido(text: string): Omit<RegionFilter, "name"> {
    const [token = "", ...rest] = text.trim().split(/\s+/);
    let sido = normalizeSido(token);
    if (sido === MERGED_GWANGJU_JEONNAM && rest.length > 0) {
        sido = rest[0].endsWith("구") ? "광주" : "전남";
    }
    return {sido, rest: rest.join(" ")};
}

/** "부산광역시 해운대구,서울특별시 전체" → 지역 필터 목록 */
export function parseRegions(value: unknown): RegionFilter[] {
    if (typeof value !== "string") return [];
    return value
        .slice(0, 1000)
        .split(",")
        .map((name) => name.trim())
        .filter((name) => name !== "")
        .map((name) => {
            const {sido, rest} = splitSido(name.replace(/\s*전체$/, ""));
            return {name, sido, rest};
        });
}

export function isInRegions(address: string, regions: RegionFilter[]): boolean {
    const target = splitSido(address);
    return regions.some(({sido, rest}) =>
        (sido === target.sido || sido === MERGED_GWANGJU_JEONNAM) &&
        (rest === "" || target.rest === rest || target.rest.startsWith(`${rest} `)));
}
