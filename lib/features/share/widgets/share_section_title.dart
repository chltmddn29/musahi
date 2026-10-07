import 'package:flutter/material.dart';
import 'package:musahi/core/constants/font.dart';

class ShareSectionTitle extends StatelessWidget {
  final String text;

  const ShareSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
