import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/info_card.dart';

/// 오류 문구와 다시 시도 버튼.
class ShelterErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ShelterErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CaptionText(
              message,
              size: CaptionSize.medium,
              align: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(onPressed: onRetry, child: '다시 시도'),
          ],
        ),
      ),
    );
  }
}
