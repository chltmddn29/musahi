import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap 타일·출처 표기를 갖춘 지도. [layers]를 타일 위에 순서대로 그린다.
class OsmMap extends StatelessWidget {
  /// 처음 화면에 모두 보이게 할 좌표들.
  final List<LatLng> fitCoordinates;
  final List<Widget> layers;

  /// 지도 위를 덮는 UI 영역. 카메라와 출처 표기가 이 안쪽에 맞춰진다.
  final EdgeInsets padding;
  final double maxZoom;

  const OsmMap({
    super.key,
    required this.fitCoordinates,
    this.layers = const [],
    this.padding = EdgeInsets.zero,
    this.maxZoom = 17,
  });

  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _userAgentPackageName = 'com.example.musahi';

  /// 마커가 가장자리에 붙지 않도록 남기는 여백.
  static const _markerMargin = EdgeInsets.all(48);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: fitCoordinates,
          padding: padding + _markerMargin,
          maxZoom: maxZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: _userAgentPackageName,
        ),
        ...layers,
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
