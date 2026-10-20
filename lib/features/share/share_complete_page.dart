import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/l10n/app_localizations.dart';

/// 실제 전송 결과가 아닌, 완료 화면을 확인하기 위한 데이터 스냅샷.
class SafetySharePreview {
  final List<String> contactNames;
  final DateTime createdAt;

  SafetySharePreview({
    required Iterable<String> contactNames,
    required this.createdAt,
  }) : contactNames = List.unmodifiable(contactNames);
}

class ShareCompletePage extends StatelessWidget {
  final SafetySharePreview? preview;

  const ShareCompletePage({super.key, this.preview});

  String _formatTime(AppLocalizations l10n, DateTime time) {
    final localTime = time.toLocal();
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(localTime, now);
    return isToday
        ? l10n.shareTodayAt(DateFormat('HH:mm').format(localTime))
        : DateFormat('yyyy.MM.dd HH:mm').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = preview;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data != null) ...[
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 38,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.sharePreviewDone,
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.sharePreviewNotSent,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${l10n.sharePreviewTargets(data.contactNames.join(', '))}\n'
                        '${_formatTime(l10n, data.createdAt)}',
                        style: AppTextStyles.captionMedium,
                        textAlign: TextAlign.center,
                      ),
                    ] else
                      Text(
                        l10n.shareNoData,
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => context.go('/info'),
                      child: Text(
                        l10n.shareBackHome,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
