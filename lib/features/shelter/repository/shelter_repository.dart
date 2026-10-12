import 'package:dio/dio.dart';
import 'package:musahi/core/constants/api.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/service/location_service.dart';

/// [nearby]: 내 주변 대피소, [region]: 내가 재난 지역 밖일 때 그 지역 안의 대피소.
enum ShelterSearchMode { nearby, region }

/// [currentLocation]은 모드와 관계없이 사용자 현재 위치(경로 출발점)다.
typedef NearbyShelters = ({
  Coordinate currentLocation,
  List<Shelter> shelters,
  ShelterSearchMode mode,
});

class ShelterRepository {
  ShelterRepository._();

  static final instance = ShelterRepository._();

  static const _limit = 5;

  final _dio = Dio(BaseOptions(baseUrl: functionsBaseUrl));

  /// 민방위 대피시설을 거리순으로 반환한다.
  /// [disasterRegion](재난문자 수신지역명)을 주면 내가 그 지역 밖일 때 지역 안의 대피소를 반환한다.
  Future<NearbyShelters> fetchNearby({String? disasterRegion}) async {
    final location = await LocationService.instance.currentLocation();
    final response = await _dio.get<Map<String, dynamic>>(
      '/nearbyShelters',
      queryParameters: {
        'lat': location.latitude,
        'lng': location.longitude,
        'limit': _limit,
        'regions': ?disasterRegion,
      },
    );
    final data = response.data!;
    final shelters = [
      for (final json in data['shelters'] as List)
        Shelter.fromJson(json as Map<String, dynamic>),
    ];

    return (
      currentLocation: location,
      shelters: shelters,
      mode: data['mode'] == ShelterSearchMode.region.name
          ? ShelterSearchMode.region
          : ShelterSearchMode.nearby,
    );
  }
}
