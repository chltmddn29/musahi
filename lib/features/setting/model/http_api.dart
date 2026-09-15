import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:musahi/features/setting/model/region_model.dart';

class RegionApiService {
  static const String _baseUrl = 'https://sgisapi.kostat.go.kr/OpenAPI3';

  final String _consumerKey;
  final String _consumerSecret;

  String? _accessToken;
  DateTime? _accessTokenExpiresAt;

  RegionApiService({
    required String consumerKey,
    required String consumerSecret,
  }) : _consumerKey = consumerKey,
       _consumerSecret = consumerSecret;

  Future<void> _ensureAccessToken() async {
    final now = DateTime.now();
    if (_accessToken != null &&
        _accessTokenExpiresAt != null &&
        now.isBefore(_accessTokenExpiresAt!)) {
      return; // 아직 유효한 토큰이 있으면 재발급 안 함
    }

    final uri = Uri.parse('$_baseUrl/auth/authentication.json').replace(
      queryParameters: {
        'consumer_key': _consumerKey,
        'consumer_secret': _consumerSecret,
      },
    );

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['errCd'] != 0) {
      throw Exception('SGIS 인증 실패: ${body['errMsg']}');
    }

    final result = body['result'] as Map<String, dynamic>;
    _accessToken = result['accessToken'] as String;

    // accessTimeout은 만료 시각(ms)이 아니라 유효기간(ms)일 수 있어
    // 실제 응답을 보고 필요시 계산 방식을 조정해주세요.
    // 우선 안전하게 3시간 후 만료로 처리(SGIS 유효기간은 보통 4시간).
    _accessTokenExpiresAt = now.add(const Duration(hours: 3));
  }

  /// cd가 null이면 시도 목록, cd를 넘기면 해당 지역의 하위 목록을 조회
  Future<List<RegionItem>> fetchRegions({String? cd}) async {
    await _ensureAccessToken();

    final uri = Uri.parse('$_baseUrl/addr/stage.json').replace(
      queryParameters: {'accessToken': _accessToken!, if (cd != null) 'cd': cd},
    );

    final response = await http.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['errCd'] != 0) {
      throw Exception('지역 조회 실패: ${body['errMsg']}');
    }

    final List<dynamic> result = body['result'] as List<dynamic>;
    return result
        .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
