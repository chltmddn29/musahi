import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';

/// 재난문자 상세 페이지. [InfoPage]의 카드를 탭하면 전체 내용을 보여준다.
class DisasterDetailPage extends StatelessWidget {
  const DisasterDetailPage({super.key, required this.message});

  final DisasterMessage message;

  @override
  Widget build(BuildContext context) {
    final meta = [
      message.regionName,
      message.createdAt,
    ].where((e) => e.isNotEmpty).join(' · ');

    return BaseScaffold(
      appBar: const CustomAppBar(title: '재난문자 상세', icon: true),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _SeverityTag(message.severity),
                  const SizedBox(height: 12),
                  Text(message.title, style: AppTextStyles.titleMedium),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    CaptionText(meta),
                  ],
                  const SizedBox(height: 16),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  const SizedBox(height: 16),
                  const _LocationPreview(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () => context.go('/shelter'),
              child: '가까운 대피소 보기',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// 심각도 배지. [InfoCard]의 [SeverityBadge]와 달리 옅은 배경 + 색 텍스트 조합.
class _SeverityTag extends StatelessWidget {
  const _SeverityTag(this.severity);

  final String severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.severityBackground(severity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity,
        style: AppTextStyles.label.copyWith(
          color: AppColors.severityColor(severity),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 대피소 경로 화면 진입 전 위치 미리보기 자리표시자.
class _LocationPreview extends StatelessWidget {
  const _LocationPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.location_on_outlined,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }
}
