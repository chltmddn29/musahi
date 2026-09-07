import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';


/// 무사히 디자인 시스템 타이포그래피 토큰
/// 출처: Notion "🤖 Claude Design 프롬프트 & 디자인 시스템"
///
/// 폰트: Pretendard
/// 제목 SemiBold, 본문 Regular, 버튼 Medium
/// 위급 화면만 예외로 Bold + 평소의 1.5배 크기
///
/// 사용 전 준비물:
/// 1. pubspec.yaml에 google_fonts 또는 로컬 Pretendard 폰트 에셋 등록
///    (google_fonts는 Pretendard 미지원이라, 로컬 에셋 방식을 권장:
///     https://cactus.tistory.com/306 등에서 Pretendard 폰트 파일 받아
///     assets/fonts/ 에 넣고 pubspec.yaml에 fontFamily 등록)
/// 2. MaterialApp의 theme에 fontFamily: 'Pretendard' 지정
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Pretendard';

  // ── 제목 (SemiBold 20–24sp) ──────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // ── 본문 (Regular 14–16sp) ───────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  // ── 카드/행 제목 (SemiBold 15sp) ─────────
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // ── 캡션 (제목 아래 보조 회색 텍스트) ───────
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.muted,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.muted,
  );

  // ── 강조/버튼 (Medium 16sp) ───────────────
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.surface,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ── 위급 전용 (Bold, 평소의 1.5배 크기) ─────
  // 위급 팝업(③번 화면)에서만 사용. 평소 제목(titleLarge 24sp)의 1.5배 → 36sp
  static const TextStyle criticalTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.surface, // 브릭레드 배경 위 흰 텍스트
  );

  static const TextStyle criticalBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24, // bodyLarge(16) x 1.5
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );
}