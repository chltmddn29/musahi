import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

/// 회색 라운드 입력창 공통 컴포넌트.
///
/// [label]을 주면 입력창 위에 라벨이 붙는 폼 필드 형태(이름, 전화번호 등)로,
/// [prefixIcon]을 주면 아이콘이 붙는 검색창 형태(지역 검색 등)로 동작한다.
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
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
            : Icon(prefixIcon, color: AppColors.muted),
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
