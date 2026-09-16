import 'package:dio/dio.dart';
import 'package:musahi/features/setting/model/region_model.dart';

class RegionRepository {
  static const String _baseUrl = 'https://sgisapi.kostat.go.kr/OpenAPI3';

  final String _consumerKey;
  final String _consumerSecret;
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  String? _accessToken;
  DateTime? _accessTokenExpiresAt;

  RegionRepository({required String consumerKey, required String consumerSecret})
    : _consumerKey = consumerKey,
      _consumerSecret = consumerSecret;

  Future<void> _ensureAccessToken() async {
    final now = DateTime.now();
    if (_accessToken != null &&
        _accessTokenExpiresAt != null &&
        now.isBefore(_accessTokenExpiresAt!)) {
      return; // 아직 유효한 토큰이 있으면 재발급 안 함
    }

    final response = await _dio.get(
      '/auth/authentication.json',
      queryParameters: {
        'consumer_key': _consumerKey,
        'consumer_secret': _consumerSecret,
      },
    );
    final body = response.data as Map<String, dynamic>;

    if (body['errCd'] != 0) {
      throw Exception('SGIS 인증 실패: ${body['errMsg']}');
    }

    final result = body['result'] as Map<String, dynamic>;
    _accessToken = result['accessToken'] as String;

    _accessTokenExpiresAt = now.add(const Duration(hours: 3));
  }

  Future<List<RegionItem>> fetchRegions({String? cd}) async {
    await _ensureAccessToken();

    final response = await _dio.get(
      '/addr/stage.json',
      queryParameters: {'accessToken': _accessToken!, if (cd != null) 'cd': cd},
    );
    final body = response.data as Map<String, dynamic>;

    if (body['errCd'] != 0) {
      throw Exception('지역 조회 실패: ${body['errMsg']}');
    }

    final List<dynamic> result = body['result'] as List<dynamic>;
    return result
        .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
