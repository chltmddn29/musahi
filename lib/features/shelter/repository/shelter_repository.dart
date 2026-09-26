import 'package:dio/dio.dart';
import 'package:musahi/core/constants/api.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/service/location_service.dart';

typedef NearbyShelters = ({Coordinate origin, List<Shelter> shelters});

class ShelterRepository {
  ShelterRepository._();

  static final instance = ShelterRepository._();

  static const _limit = 5;

  final _dio = Dio(BaseOptions(baseUrl: functionsBaseUrl));

  /// 현재 위치 기준 가까운 민방위 대피시설을 거리순으로 반환한다.
  Future<NearbyShelters> fetchNearby() async {
    final origin = await LocationService.instance.currentLocation();
    final response = await _dio.get<Map<String, dynamic>>(
      '/nearbyShelters',
      queryParameters: {
        'lat': origin.latitude,
        'lng': origin.longitude,
        'limit': _limit,
      },
    );
    final shelters = [
      for (final json in response.data!['shelters'] as List)
        Shelter.fromJson(json as Map<String, dynamic>),
    ];
    return (origin: origin, shelters: shelters);
  }
}
