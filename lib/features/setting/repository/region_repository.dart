import 'package:dio/dio.dart';
import 'package:musahi/features/setting/model/region_model.dart';

/// SGIS consumer_key/secret은 클라이언트 코드/바이너리에 절대 포함하지 않는다.
/// 인증과 조회는 모두 Firebase Functions의 `sgisRegions`가 대신 수행하고,
/// 이 클래스는 그 결과만 가져온다.
class RegionRepository {
  static const String _baseUrl =
      'https://asia-northeast3-musahi-app.cloudfunctions.net';

  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<List<RegionItem>> fetchRegions({String? cd}) async {
    final response = await _dio.get(
      '/sgisRegions',
      queryParameters: {if (cd != null) 'cd': cd},
    );
    final body = response.data as Map<String, dynamic>;

    final List<dynamic> result = body['result'] as List<dynamic>;
    return result
        .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
