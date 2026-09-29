// 대피소 데이터 변환·검색 로직. 외부 API·DB와 분리해 단위 테스트할 수 있게 한다.
import {RegionFilter, isInRegions} from "./region_match";

/** [id, 이름, 주소, 위도, 경도] — 문서 크기를 줄이기 위한 압축 형태 */
export type ShelterRow = [string, string, string, number, number];

/**
 * 포털은 인코딩/디코딩 키를 함께 준다. axios에 맡기면 인코딩 키가 이중 인코딩되므로
 * 인코딩된 형태로 맞춰 URL에 직접 넣는다.
 */
export function toEncodedKey(apiKey: string): string {
    const key = apiKey.trim();
    return key.includes("%") ? key : encodeURIComponent(key);
}

export function toShelterRow(item: any): ShelterRow | null {
    const lat = Number(item.LAT_EPSG4326);
    const lng = Number(item.LOT_EPST4326); // 명세상 필드명 오타(EPST) 그대로
    const isInKorea = lat > 33 && lat < 39 && lng > 124 && lng < 132;
    const isRemoved = Boolean(item.RMV_YMD?.trim());
    if (!item.FCLT_NM || !isInKorea || isRemoved) return null;

    return [
        String(item.MNG_NO || `${lat},${lng}`),
        String(item.FCLT_NM).trim(),
        String(item.ROAD_NM_WHOL_ADDR || item.LCTN_WHOL_ADDR || "").trim(),
        Number(lat.toFixed(6)),
        Number(lng.toFixed(6)),
    ];
}

export function distanceMeters(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const toRad = (deg: number) => (deg * Math.PI) / 180;
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
    return 2 * 6371000 * Math.asin(Math.sqrt(a));
}

export interface Point {
    lat: number;
    lng: number;
}

export function nearestTo(rows: ShelterRow[], point: Point): ShelterRow[] {
    const distanceOf = ([, , , lat, lng]: ShelterRow) => distanceMeters(point.lat, point.lng, lat, lng);
    return [...rows].sort((a, b) => distanceOf(a) - distanceOf(b));
}

export function centroidOf(rows: ShelterRow[]): Point {
    const sum = rows.reduce((acc, [, , , lat, lng]) => ({lat: acc.lat + lat, lng: acc.lng + lng}), {lat: 0, lng: 0});
    return {lat: sum.lat / rows.length, lng: sum.lng / rows.length};
}

/**
 * 사용자가 재난 지역 안에 있거나 지역이 없으면 내 주변(nearby),
 * 지역 밖에 있으면 그 지역 중심 주변의 지역 내 대피소(region)를 반환한다.
 * 거리는 항상 사용자 위치 기준이다.
 */
export function searchShelters(rows: ShelterRow[], user: Point, regions: RegionFilter[], limit: number) {
    const toResponse = ([id, name, address, lat, lng]: ShelterRow) => ({
        id, name, address, lat, lng,
        distanceMeters: Math.round(distanceMeters(user.lat, user.lng, lat, lng)),
    });

    const nearby = nearestTo(rows, user);
    // 내게 가장 가까운 대피소가 재난 지역 안이면 나도 그 지역에 있다고 본다.
    const isUserInRegion = nearby.length > 0 && isInRegions(nearby[0][2], regions);
    const regionRows = rows.filter(([, , address]) => isInRegions(address, regions));

    if (regions.length === 0 || isUserInRegion || regionRows.length === 0) {
        return {mode: "nearby", shelters: nearby.slice(0, limit).map(toResponse)};
    }

    // 지역 중심 주변 대피소를 고른 뒤, 표시되는 거리(사용자 기준) 순으로 정렬한다.
    const center = centroidOf(regionRows);
    const aroundCenter = nearestTo(regionRows, center).slice(0, limit);
    return {
        mode: "region",
        center,
        shelters: nearestTo(aroundCenter, user).map(toResponse),
    };
}

/** 지역 내 대피소의 중심과, 대부분(90%)을 포함하는 반경. 섬 등 외곽값에 원이 커지지 않게 한다. */
export function areaOf(region: RegionFilter, rows: ShelterRow[]) {
    const regionRows = rows.filter(([, , address]) => isInRegions(address, [region]));
    if (regionRows.length === 0) return null;

    const center = centroidOf(regionRows);
    const distances = regionRows
        .map(([, , , lat, lng]) => distanceMeters(center.lat, center.lng, lat, lng))
        .sort((a, b) => a - b);
    const radiusMeters = distances[Math.floor((distances.length - 1) * 0.9)];

    return {name: region.name, center, radiusMeters: Math.round(radiusMeters)};
}
