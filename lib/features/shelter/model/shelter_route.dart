import 'package:musahi/features/shelter/model/shelter.dart';

/// 경로 안내 화면 진입 인자.
typedef RouteTarget = ({Coordinate origin, Shelter destination});

enum TurnDirection { straight, left, right }

/// 다음 안내 지점. [description]은 경로 API가 내려주는 안내 문구.
class RouteStep {
  final TurnDirection direction;
  final String description;

  const RouteStep({required this.direction, required this.description});
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
}
