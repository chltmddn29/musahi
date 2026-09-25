import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/widgets/dashed_route_painter.dart';
import 'package:musahi/features/shelter/widgets/map_markers.dart';

/// 지도 SDK 연동 전 임시 지도.
/// 현재 위치·핀·경로가 모두 보이도록 [padding] 안쪽 영역에 맞춰 배치한다.
class ShelterMap extends StatelessWidget {
  final Coordinate origin;
  final List<Coordinate> pins;
  final List<Coordinate> route;

  /// 지도 위를 덮는 UI(시트, 패널 등) 영역. 이 안쪽에만 마커를 그린다.
  final EdgeInsets padding;

  const ShelterMap({
    super.key,
    required this.origin,
    this.pins = const [],
    this.route = const [],
    this.padding = EdgeInsets.zero,
  });

  /// 마커가 가장자리에 붙지 않도록 남기는 여백.
  static const double _markerMargin = 40;

  static const _background = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(-0.92, -0.92),
    colors: [
      Color(0xFFE4EAF1),
      Color(0xFFE4EAF1),
      Color(0xFFDAE3EC),
      Color(0xFFDAE3EC),
    ],
    stops: [0, 0.5, 0.5, 1],
    tileMode: TileMode.repeated,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _background),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final area = padding
              .deflateRect(Offset.zero & constraints.biggest)
              .deflate(_markerMargin);
          final projection = _Projection([origin, ...pins, ...route], area);

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DashedRoutePainter(
                    route.map(projection.toOffset).toList(),
                  ),
                ),
              ),
              for (final pin in pins)
                _centeredAt(
                  projection.toOffset(pin) -
                      const Offset(0, ShelterPinMarker.tipOffset),
                  ShelterPinMarker.size,
                  const ShelterPinMarker(),
                ),
              _centeredAt(
                projection.toOffset(origin),
                CurrentLocationMarker.size,
                const CurrentLocationMarker(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _centeredAt(Offset center, double size, Widget marker) => Positioned(
    left: center.dx - size / 2,
    top: center.dy - size / 2,
    child: marker,
  );
}

/// 위경도 → 화면 좌표 변환. 모든 점의 경계가 [area] 안에 들어오도록 축척을 맞춘다.
class _Projection {
  final Rect area;
  final double _centerLat;
  final double _centerLng;
  final double _scale;

  factory _Projection(List<Coordinate> points, Rect area) {
    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    final minLat = lats.reduce(math.min), maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min), maxLng = lngs.reduce(math.max);
    final span = math.max(math.max(maxLat - minLat, maxLng - minLng), 1e-6);

    return _Projection._(
      area,
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
      math.min(area.width, area.height) / span,
    );
  }

  _Projection._(this.area, this._centerLat, this._centerLng, this._scale);

  Offset toOffset(Coordinate point) =>
      area.center +
      Offset(
        (point.longitude - _centerLng) * _scale,
        (_centerLat - point.latitude) * _scale,
      );
}
