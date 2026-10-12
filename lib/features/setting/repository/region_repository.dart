import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:musahi/features/setting/model/region_model.dart';

class RegionRepository {
  static const _functionsBaseUrl =
      'https://asia-northeast3-musahi-app.cloudfunctions.net';

  final Dio _dio = Dio(BaseOptions(baseUrl: _functionsBaseUrl));

  /// SGIS 인증은 Firebase Functions에서만 수행한다.
  Future<List<RegionItem>> fetchRegions({String? cd}) async {
    final response = await _dio.get(
      '/sgisRegions',
      queryParameters: {'cd': ?cd},
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data['result'] is! List) {
      throw const FormatException('Invalid SGIS region response');
    }
    return (data['result'] as List).map((entry) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid SGIS region item');
      }
      return RegionItem.fromJson(entry);
    }).toList();
  }

  /// 재난문자 발송 서버가 수집한 수신지역 코드와 이름을 가져온다.
  Future<List<RegionItem>> fetchNotificationRegions() async {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'musahi',
    );
    final snapshot = await db.collection('regions').get();
    return snapshot.docs
        .map((doc) => RegionItem.fromDisasterRegion(doc.data()))
        .toList();
  }
}
