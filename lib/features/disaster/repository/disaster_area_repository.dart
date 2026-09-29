import 'package:dio/dio.dart';
import 'package:musahi/core/constants/api.dart';
import 'package:musahi/features/disaster/model/disaster_area.dart';

class DisasterAreaRepository {
  DisasterAreaRepository._();

  static final instance = DisasterAreaRepository._();

  final _dio = Dio(BaseOptions(baseUrl: functionsBaseUrl));

  /// [regionName](재난문자 수신지역명, 쉼표 구분)의 위치를 반환한다. 알 수 없는 지역은 빠진다.
  Future<List<DisasterArea>> fetchAreas(String regionName) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/disasterAreas',
      queryParameters: {'regions': regionName},
    );
    return [
      for (final json in response.data!['areas'] as List)
        DisasterArea.fromJson(json as Map<String, dynamic>),
    ];
  }
}
