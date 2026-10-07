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

  factory RouteStep.fromJson(Map<String, dynamic> json) => RouteStep(
    direction:
        TurnDirection.values.asNameMap()[json['direction']] ??
        TurnDirection.straight,
    description: json['description'] as String,
  );
}

class ShelterRoute {
  final List<Coordinate> path;
  final int remainingMeters;
  final Duration remainingTime;
  final RouteStep nextStep;

  const ShelterRoute({
    required this.path,
    required this.remainingMeters,
    required this.remainingTime,
    required this.nextStep,
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
