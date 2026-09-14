import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final Icon? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon?.icon, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.mutedSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon == null ? 16 : 0,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label!, style: AppTextStyles.cardTitle),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
