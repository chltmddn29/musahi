import {defineSecret} from "firebase-functions/params";
import axios from "axios";

// SGIS consumer_key/secret은 클라이언트에 절대 포함하지 않고, Functions 시크릿으로만 보관한다.
export const sgisConsumerKey = defineSecret("SGIS_CONSUMER_KEY");
export const sgisConsumerSecret = defineSecret("SGIS_CONSUMER_SECRET");

export const SGIS_API_URL = "https://sgisapi.mods.go.kr/OpenAPI3";
/** 토큰이 만료·무효일 때 SGIS가 주는 오류 코드 (잘못된 토큰으로 호출해 확인). */
const SGIS_AUTH_ERROR = -401;
const WGS84 = "4326";
const UTM_K = "5179";

/** SGIS가 오류 코드(errCd)로 거부한 요청. */
export class SgisError extends Error {
    constructor(readonly errCd: number, message: string) {
        super(message);
    }
}

export function isSgisAuthError(errCd: unknown): boolean {
    return errCd === SGIS_AUTH_ERROR;
}

let sgisAccessToken: string | null = null;
let sgisAccessTokenExpiresAt: number | null = null;

export async function ensureSgisAccessToken(): Promise<string> {
    const now = Date.now();
    if (sgisAccessToken && sgisAccessTokenExpiresAt && now < sgisAccessTokenExpiresAt) {
        return sgisAccessToken;
    }

    const response = await axios.get(`${SGIS_API_URL}/auth/authentication.json`, {
        params: {consumer_key: sgisConsumerKey.value(), consumer_secret: sgisConsumerSecret.value()},
        timeout: 15000,
    });
    const body = response.data;

    if (body.errCd !== 0) {
        throw new Error(`SGIS 인증 실패: ${body.errMsg}`);
    }

    sgisAccessToken = body.result.accessToken;
    // SGIS 액세스 토큰 유효기간은 보통 4시간이나, 여유를 두고 3시간 후 만료로 처리한다.
    sgisAccessTokenExpiresAt = now + 3 * 60 * 60 * 1000;
    return sgisAccessToken as string;
}

/** 토큰이 서버 쪽에서 만료·무효 처리됐을 때 다음 요청에 재발급하도록 초기화한다. */
export function resetSgisAccessToken(): void {
    sgisAccessToken = null;
    sgisAccessTokenExpiresAt = null;
}

async function sgisGet(path: string, params: object) {
    const accessToken = await ensureSgisAccessToken();
    const response = await axios.get(`${SGIS_API_URL}/${path}`, {
        params: {accessToken, ...params},
        timeout: 10000,
    });
    const body = response.data;
    if (body.errCd !== 0) {
        throw new SgisError(body.errCd, `SGIS ${path} 실패: ${body.errMsg}`);
    }
    return body.result;
}

/** 위경도를 행정구역 주소("부산광역시 해운대구 중동")로 바꾼다. */
export async function reverseGeocode(lat: number, lng: number): Promise<string> {
    try {
        const utmk = await sgisGet("transformation/transcoord.json", {
            src: WGS84, dst: UTM_K, posX: lng, posY: lat,
        });
        const [place] = await sgisGet("addr/rgeocode.json", {
            x_coor: utmk.posX, y_coor: utmk.posY, addr_type: 20,
        });
        return place.full_addr || [place.sido_nm, place.sgg_nm, place.emdong_nm].join(" ");
    } catch (error) {
        // 시간 초과 등은 토큰과 무관하므로 유효한 토큰을 버리지 않는다.
        if (error instanceof SgisError && isSgisAuthError(error.errCd)) resetSgisAccessToken();
        throw error;
    }
}
