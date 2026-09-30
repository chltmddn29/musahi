import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/osm_map.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/widgets/map_markers.dart';

/// 대피소 지도. 현재 위치·핀·경로가 모두 보이도록 카메라를 맞춘다.
class ShelterMap extends StatelessWidget {
  /// 없으면 현재 위치 마커를 그리지 않는다(재난 지역 밖에서 지역 대피소를 볼 때).
  final Coordinate? currentLocation;
  final List<Coordinate> pins;
  final List<Coordinate> route;

  /// 강조할 핀의 인덱스. 없으면 모든 핀을 같은 색으로 그린다.
  final int? selectedPin;
  final ValueChanged<int>? onPinTap;

  /// 지도 위를 덮는 UI(시트, 패널 등) 영역. 카메라와 출처 표기가 이 안쪽에 맞춰진다.
  final EdgeInsets padding;

  const ShelterMap({
    super.key,
    this.currentLocation,
    this.pins = const [],
    this.route = const [],
    this.selectedPin,
    this.onPinTap,
    this.padding = EdgeInsets.zero,
  });

  /// 핀의 뾰족한 끝이 좌표에 오도록 핀을 위로 올린다.
  static const _pinAlignment = Alignment(
    0,
    -ShelterPinMarker.tipOffset / (ShelterPinMarker.size / 2),
  );

  static LatLng _toLatLng(Coordinate c) => LatLng(c.latitude, c.longitude);

  @override
  Widget build(BuildContext context) {
    return OsmMap(
      fitCoordinates: [
        ?currentLocation,
        ...pins,
        ...route,
      ].map(_toLatLng).toList(),
      padding: padding,
      layers: [
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route.map(_toLatLng).toList(),
                color: AppColors.primary,
                strokeWidth: 4,
                pattern: StrokePattern.dashed(segments: const [10, 8]),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final (index, pin) in pins.indexed)
              Marker(
                point: _toLatLng(pin),
                width: ShelterPinMarker.size,
                height: ShelterPinMarker.size,
                alignment: _pinAlignment,
                child: GestureDetector(
                  onTap: onPinTap == null ? null : () => onPinTap!(index),
                  child: ShelterPinMarker(
                    dimmed: selectedPin != null && selectedPin != index,
                  ),
                ),
              ),
            if (currentLocation case final location?)
              Marker(
                point: _toLatLng(location),
                width: CurrentLocationMarker.size,
                height: CurrentLocationMarker.size,
                child: const CurrentLocationMarker(),
              ),
          ],
        ),
      ],
    );
  }
}
