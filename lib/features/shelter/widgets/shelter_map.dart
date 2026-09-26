import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/widgets/map_markers.dart';

/// OpenStreetMap 지도. 현재 위치·핀·경로가 모두 보이도록 카메라를 맞춘다.
class ShelterMap extends StatelessWidget {
  final Coordinate origin;
  final List<Coordinate> pins;
  final List<Coordinate> route;

  /// 지도 위를 덮는 UI(시트, 패널 등) 영역. 카메라와 출처 표기가 이 안쪽에 맞춰진다.
  final EdgeInsets padding;

  const ShelterMap({
    super.key,
    required this.origin,
    this.pins = const [],
    this.route = const [],
    this.padding = EdgeInsets.zero,
  });

  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _userAgentPackageName = 'com.example.musahi';

  /// 마커가 가장자리에 붙지 않도록 남기는 여백.
  static const _markerMargin = EdgeInsets.all(48);

  /// 핀의 뾰족한 끝이 좌표에 오도록 핀을 위로 올린다.
  static const _pinAlignment = Alignment(
    0,
    -ShelterPinMarker.tipOffset / (ShelterPinMarker.size / 2),
  );

  static LatLng _toLatLng(Coordinate c) => LatLng(c.latitude, c.longitude);

  @override
  Widget build(BuildContext context) {
    final originLatLng = _toLatLng(origin);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: [
            originLatLng,
            ...[...pins, ...route].map(_toLatLng),
          ],
          padding: padding + _markerMargin,
          maxZoom: 17,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: _userAgentPackageName,
        ),
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
            for (final pin in pins)
              Marker(
                point: _toLatLng(pin),
                width: ShelterPinMarker.size,
                height: ShelterPinMarker.size,
                alignment: _pinAlignment,
                child: const ShelterPinMarker(),
              ),
            Marker(
              point: originLatLng,
              width: CurrentLocationMarker.size,
              height: CurrentLocationMarker.size,
              child: const CurrentLocationMarker(),
            ),
          ],
        ),
        Padding(
          padding: padding,
          child: const RichAttributionWidget(
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ),
      ],
    );
  }
}
