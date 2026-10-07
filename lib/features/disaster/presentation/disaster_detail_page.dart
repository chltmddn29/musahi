import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';
import 'package:musahi/features/disaster/widgets/disaster_area_map.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';

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
                  if (message.regionName.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DisasterAreaMap(regionName: message.regionName),
                  ],
                ],
              ),
            ),
          ),
          if (DisasterGuide.of(message.category) != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: () => context.push('/guide-detail', extra: message),
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                borderColor: AppColors.primary.withValues(alpha: 0.4),
                child: '행동요령 보기',
              ),
            ),
          ],
          if (message.needsShelter) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: () => context.push(
                  '/disaster-shelters',
                  extra: message.regionName.isEmpty ? null : message.regionName,
                ),
                child: '대피소 보기',
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
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
