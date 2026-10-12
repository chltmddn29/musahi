import 'package:musahi/features/shelter/model/shelter.dart';

/// 경로 안내 화면 진입 인자.
typedef RouteTarget = ({Coordinate origin, Shelter destination});

enum TurnDirection { straight, left, right }

/// 다음 안내 지점. [description]은 경로 API가 내려주는 안내 문구.
class RouteStep {
  final TurnDirection direction;
  final String description;

  const RouteStep({required this.direction, required this.description});

  static const headToShelter = RouteStep(
    direction: TurnDirection.straight,
    description: '대피소 방향으로 이동하세요',
  );

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final description = (json['description'] as String?)?.trim();
    return RouteStep(
      direction:
          TurnDirection.values.asNameMap()[json['direction']] ??
          TurnDirection.straight,
      // 경로 API가 안내 문구를 비워 주면 대피소 방향 안내로 대신한다.
      description: description == null || description.isEmpty
          ? headToShelter.description
          : description,
    );
  }
}

class ShelterRoute {
  final List<Coordinate> path;
  final int remainingMeters;
  final Duration remainingTime;
  final RouteStep nextStep;

  /// 경로 API 없이 직선 거리로 추정한 값이면 true.
  final bool isEstimated;

  const ShelterRoute({
    required this.path,
    required this.remainingMeters,
    required this.remainingTime,
    required this.nextStep,
    this.isEstimated = false,
  });

  factory ShelterRoute.fromJson(Map<String, dynamic> json) {
    final steps = json['steps'] as List;
    return ShelterRoute(
      path: [
        for (final point in json['path'] as List)
          Coordinate(
            (point[0] as num).toDouble(),
            (point[1] as num).toDouble(),
          ),
      ],
      remainingMeters: (json['totalDistance'] as num).toInt(),
      remainingTime: Duration(seconds: (json['totalTime'] as num).toInt()),
      nextStep: steps.isEmpty
          ? RouteStep.headToShelter
          : RouteStep.fromJson(steps.first as Map<String, dynamic>),
    );
  }
}
