import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/core/widgets/osm_map.dart';
import 'package:musahi/features/disaster/model/disaster_area.dart';
import 'package:musahi/features/disaster/repository/disaster_area_repository.dart';

/// 재난문자 수신지역을 반투명 원과 경고 마커로 표시하는 지도.
class DisasterAreaMap extends StatefulWidget {
  final String regionName;

  const DisasterAreaMap({super.key, required this.regionName});

  @override
  State<DisasterAreaMap> createState() => _DisasterAreaMapState();
}

class _DisasterAreaMapState extends State<DisasterAreaMap> {
  static const double _height = 200;

  late final Future<List<DisasterArea>> _areas = DisasterAreaRepository.instance
      .fetchAreas(widget.regionName);

  static LatLng _toLatLng(DisasterArea area) =>
      LatLng(area.center.latitude, area.center.longitude);

  /// 원 전체가 보이도록 원의 동서남북 끝점을 카메라 영역에 넣는다.
  static Iterable<LatLng> _circleBounds(DisasterArea area) => [
    for (final bearing in const [0.0, 90.0, 180.0, 270.0])
      const Distance().offset(_toLatLng(area), area.radiusMeters, bearing),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: _height,
        child: FutureBuilder<List<DisasterArea>>(
          future: _areas,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _MapPlaceholder(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            final areas = snapshot.data ?? const [];
            if (areas.isEmpty) {
              return const _MapPlaceholder(
                child: CaptionText('재난 지역 위치를 표시할 수 없습니다.'),
              );
            }
            return _buildMap(areas);
          },
        ),
      ),
    );
  }

  Widget _buildMap(List<DisasterArea> areas) {
    return OsmMap(
      fitCoordinates: areas.expand(_circleBounds).toList(),
      maxZoom: 15,
      layers: [
        CircleLayer(
          circles: [
            for (final area in areas)
              CircleMarker(
                point: _toLatLng(area),
                radius: area.radiusMeters,
                useRadiusInMeter: true,
                color: AppColors.alertCritical.withValues(alpha: 0.15),
                borderColor: AppColors.alertCritical,
                borderStrokeWidth: 1.5,
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            for (final area in areas)
              Marker(
                point: _toLatLng(area),
                width: 32,
                height: 32,
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.alertCritical,
                  size: 32,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final Widget child;

  const _MapPlaceholder({required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(child: child),
    );
  }
}
