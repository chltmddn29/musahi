import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Base ──────────────────────────────
  static const Color primary = Color(0xFF5E86B0); // 차분한 파랑 — 앱바, 주요 버튼, 강조 요소
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF); // 카드
  static const Color text = Color(0xFF1C1C1E);
  static const Color muted = Color(0xFF8E8E93);

  // ── Alert ─────────────────────────────
  static const Color alertCritical = Color(0xFFC1594A); // 위급 — 브릭레드
  static const Color alertUrgent = Color(0xFFD99B4E); // 긴급 — 머스타드 앰버
  static const Color success = Color(0xFF6FA87D); // 안전/완료 — 뮤트 그린

  /// 안전안내 배너/태그용 뮤트 그레이 (Muted를 옅게 깐 버전)
  static const Color mutedSurface = Color(0xFFEEEEEF);

  /// 그룹 리스트 행 사이 구분선
  static const Color divider = Color(0xFFF2F2F2);

  /// 카드 공통 그림자
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// 심각도 문자열("위급"/"긴급"/"안전안내")로 컬러를 가져오는 헬퍼.
  /// 서버 FCM data payload의 `severity` 필드와 그대로 매칭해서 쓰면 됨.
  static Color severityColor(String severity) {
    switch (severity) {
      case '위급':
        return alertCritical;
      case '긴급':
        return alertUrgent;
      default: // 안전안내 등
        return muted;
    }
  }

  /// 심각도 배지(태그) 배경색 — 텍스트 컬러보다 옅게
  static Color severityBackground(String severity) {
    switch (severity) {
      case '위급':
        return alertCritical.withOpacity(0.12);
      case '긴급':
        return alertUrgent.withOpacity(0.16);
      default:
        return mutedSurface;
    }
  }
}