import 'package:dio/dio.dart';
import 'package:musahi/core/constants/api.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';

class RouteRepository {
  RouteRepository._();

  static final instance = RouteRepository._();

  static const _walkingMetersPerMinute = 70;

  final _dio = Dio(BaseOptions(baseUrl: functionsBaseUrl));

  /// 도보 경로를 흘려보낸다. 위치 추적 기반 재탐색은 이 스트림에 이어 붙인다.
  Stream<ShelterRoute> watchWalkingRoute(RouteTarget target) =>
      Stream.fromFuture(_fetchWalkingRoute(target));

  Future<ShelterRoute> _fetchWalkingRoute(RouteTarget target) async {
    final (:origin, :destination) = target;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/walkingRoute',
        queryParameters: {
          'startLat': origin.latitude,
          'startLng': origin.longitude,
          'endLat': destination.location.latitude,
          'endLng': destination.location.longitude,
        },
      );
      return ShelterRoute.fromJson(response.data!);
    } on Object catch (error) {
      // 재난 상황에서 안내가 끊기지 않도록 호출·파싱 실패 시 직선 경로로 대신한다.
      if (error is! DioException &&
          error is! FormatException &&
          error is! TypeError) {
        rethrow;
      }
      return _straightLineRoute(target);
    }
  }

  ShelterRoute _straightLineRoute(RouteTarget target) {
    final (:origin, :destination) = target;
    final meters = destination.distanceMeters;
    return ShelterRoute(
      path: [origin, destination.location],
      remainingMeters: meters,
      remainingTime: Duration(
        minutes: (meters / _walkingMetersPerMinute).ceil(),
      ),
      nextStep: RouteStep.headToShelter,
    );
  }
}
