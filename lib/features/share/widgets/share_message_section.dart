import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'share_section_title.dart';
import 'package:musahi/l10n/app_localizations.dart';

class ShareMessageSection extends StatelessWidget {
  final String message;
  final VoidCallback onEdit;

  const ShareMessageSection({
    super.key,
    required this.message,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: ShareSectionTitle(l10n.shareMessageTitle)),
            IconButton(
              onPressed: onEdit,
              tooltip: l10n.shareEditMessage,
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.muted,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            color: AppColors.messageSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
