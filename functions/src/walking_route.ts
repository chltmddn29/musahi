import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {defineSecret} from "firebase-functions/params";
import axios from "axios";

const tmapAppKey = defineSecret("TMAP_APP_KEY");

const TMAP_PEDESTRIAN_URL = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1";

// TMAP turnType → 앱에서 쓰는 방향. 목록에 없는 값(직진, 횡단보도 등)은 straight.
const LEFT_TURNS = new Set([12, 16, 17, 212, 214, 215]);
const RIGHT_TURNS = new Set([13, 18, 19, 213, 216, 217]);
const START_OR_END = new Set([200, 201]);

function toDirection(turnType: number): "left" | "right" | "straight" {
    if (LEFT_TURNS.has(turnType)) return "left";
    if (RIGHT_TURNS.has(turnType)) return "right";
    return "straight";
}

/** TMAP GeoJSON 응답을 앱이 쓰는 형태({path, totalDistance, totalTime, steps})로 줄인다. */
function simplifyRoute(features: any[]) {
    const summary = features[0]?.properties ?? {};
    const path: [number, number][] = [];
    const steps: {direction: string; description: string}[] = [];

    for (const {geometry, properties} of features) {
        if (geometry.type === "LineString") {
            for (const [lng, lat] of geometry.coordinates) path.push([lat, lng]);
        } else if (geometry.type === "Point" && !START_OR_END.has(properties.turnType)) {
            steps.push({direction: toDirection(properties.turnType), description: properties.description});
        }
    }

    return {
        path,
        totalDistance: summary.totalDistance ?? 0,
        totalTime: summary.totalTime ?? 0,
        steps,
    };
}

export const walkingRoute = onRequest(
    {region: "asia-northeast3", secrets: [tmapAppKey]},
    async (req, res) => {
        const [startLat, startLng, endLat, endLng] =
            ["startLat", "startLng", "endLat", "endLng"].map((key) => Number(req.query[key]));
        if (![startLat, startLng, endLat, endLng].every(Number.isFinite)) {
            res.status(400).json({error: "startLat, startLng, endLat, endLng가 필요합니다."});
            return;
        }

        try {
            const response = await axios.post(
                TMAP_PEDESTRIAN_URL,
                {
                    startX: startLng, startY: startLat,
                    endX: endLng, endY: endLat,
                    startName: encodeURIComponent("출발지"),
                    endName: encodeURIComponent("대피소"),
                    reqCoordType: "WGS84GEO",
                    resCoordType: "WGS84GEO",
                },
                {headers: {appKey: tmapAppKey.value()}, timeout: 15000}
            );
            res.status(200).json(simplifyRoute(response.data.features ?? []));
        } catch (error) {
            logger.error("TMAP 도보 경로 조회 실패", {error});
            res.status(502).json({error: "경로 조회 실패"});
        }
    }
);
