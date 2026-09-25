import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';

/// 도보 경로 데이터 소스. 현재는 목업이며, 경로 API·위치 스트림 연동 시 교체한다.
class RouteRepository {
  RouteRepository._();

  static final instance = RouteRepository._();

  static const _walkingMetersPerMinute = 70;

  /// 이동에 따라 갱신되는 도보 경로를 흘려보낸다.
  Stream<ShelterRoute> watchWalkingRoute(RouteTarget target) {
    final (:origin, :destination) = target;
    final corner = Coordinate(origin.latitude, destination.location.longitude);
    final meters = destination.distanceMeters;

    return Stream.value(
      ShelterRoute(
        path: [origin, corner, destination.location],
        remainingMeters: meters,
        remainingTime: Duration(
          minutes: (meters / _walkingMetersPerMinute).ceil(),
        ),
        nextStep: const RouteStep(
          direction: TurnDirection.right,
          description: '300m 앞에서 우회전하세요',
        ),
      ),
    );
  }
}
