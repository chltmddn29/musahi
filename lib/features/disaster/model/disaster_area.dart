import 'package:musahi/features/shelter/model/shelter.dart';

/// 재난문자 수신지역의 대략적인 위치. 지역 내 대피소 분포로 추정한 중심과 반경.
class DisasterArea {
  final String name;
  final Coordinate center;
  final double radiusMeters;

  const DisasterArea({
    required this.name,
    required this.center,
    required this.radiusMeters,
  });

  factory DisasterArea.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as Map<String, dynamic>;
    return DisasterArea(
      name: json['name'] as String,
      center: Coordinate(
        (center['lat'] as num).toDouble(),
        (center['lng'] as num).toDouble(),
      ),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
    );
  }
}
