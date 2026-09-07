import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

/// 캡션 크기. [small] 12.5sp(리스트 보조텍스트), [medium] 14sp(온보딩 설명문).
enum CaptionSize { small, medium }

/// 제목 아래 회색 보조 텍스트.
class CaptionText extends StatelessWidget {
  final String text;
  final CaptionSize size;
  final TextAlign align;
  final int? maxLines;

  /// 컬러 배경 위에 올릴 때 true → 흰색.
  final bool onColor;

  const CaptionText(
    this.text, {
    super.key,
    this.size = CaptionSize.small,
    this.align = TextAlign.start,
    this.maxLines,
    this.onColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = switch (size) {
      CaptionSize.small => AppTextStyles.captionSmall,
      CaptionSize.medium => AppTextStyles.captionMedium,
    };

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: onColor
          ? base.copyWith(color: AppColors.surface.withValues(alpha: 0.9))
          : base,
    );
  }
}

/// `[leading] + (제목 + 캡션) + [trailing]` 카드/행 틀.
/// 도메인 변형은 팩토리 생성자([InfoCard.alert] 등)로 만든다.
class InfoCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 그림자 대신 얇은 테두리.
  final bool bordered;

  /// 겉면(그림자·라운드·padding 16)을 없애고 라벨 굵기를 낮춘 행 모드.
  /// [SettingsGroup] 안의 행이 쓴다.
  final bool flat;

  final CrossAxisAlignment crossAxisAlignment;

  const InfoCard({
    super.key,
    required this.title,
    this.caption,
    this.leading,
    this.trailing,
    this.onTap,
    this.bordered = false,
    this.flat = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// 재난문자 행. [severity]는 '위급' / '긴급' / '안전안내'.
  factory InfoCard.alert({
    Key? key,
    required String title,
    required String severity,
    required String time,
    VoidCallback? onTap,
  }) =>
      InfoCard(
        key: key,
        title: title,
        caption: time,
        onTap: onTap,
        trailing: _SeverityBadge(severity),
      );

  /// 대피소 행.
  factory InfoCard.shelter({
    Key? key,
    required String name,
    required String address,
    required int distanceMeters,
    VoidCallback? onTap,
  }) =>
      InfoCard(
        key: key,
        bordered: true,
        leading: InfoCardLeading.icon(Icons.place_outlined),
        title: name,
        caption: address,
        onTap: onTap,
        trailing: Text(
          '$distanceMeters m',
          style: AppTextStyles.label.copyWith(color: AppColors.primary),
        ),
      );

  /// [SettingsGroup] 안의 한 행.
  factory InfoCard.settingsTile({
    Key? key,
    Widget? leading,
    required String label,
    String? value,
    Widget? trailing,
    bool chevron = false,
    VoidCallback? onTap,
  }) {
    Widget? composed;
    if (value != null || trailing != null || chevron) {
      composed = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) CaptionText(value),
          if (trailing != null) ...[
            if (value != null) const SizedBox(width: 12),
            trailing,
          ],
          if (chevron) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC7C7CC)),
          ],
        ],
      );
    }
    return InfoCard(
      key: key,
      flat: true,
      leading: leading,
      title: label,
      onTap: onTap,
      trailing: composed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: flat
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
          : const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style:
                      flat ? AppTextStyles.bodyMedium : AppTextStyles.cardTitle,
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  CaptionText(caption!),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    final Widget body = flat
        ? content
        : Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border:
                  bordered ? Border.all(color: const Color(0xFFEFEFEF)) : null,
              boxShadow: AppColors.cardShadow,
            ),
            child: content,
          );

    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: flat ? null : BorderRadius.circular(14),
      child: body,
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String rating;

  const _SeverityBadge(this.rating);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.severityColor(rating),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rating,
        style: AppTextStyles.label.copyWith(color: AppColors.surface),
      ),
    );
  }
}

/// [InfoCard.leading] 슬롯용 아이콘·뱃지 3종.
class InfoCardLeading extends StatelessWidget {
  final Widget child;
  final double size;
  final Color background;
  final BorderRadius radius;

  const InfoCardLeading._({
    required this.child,
    required this.size,
    required this.background,
    required this.radius,
  });

  /// 번호 뱃지 (행동요령).
  factory InfoCardLeading.number(int value) => InfoCardLeading._(
        size: 28,
        background: AppColors.primary,
        radius: BorderRadius.circular(14),
        child: Text(
          '$value',
          style: AppTextStyles.label.copyWith(
            color: AppColors.surface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  /// 아이콘 박스. 기본 36, 설정 행은 [boxSize] 32.
  factory InfoCardLeading.icon(IconData icon, {double boxSize = 36}) =>
      InfoCardLeading._(
        size: boxSize,
        background: AppColors.primary.withValues(alpha: 0.1),
        radius: BorderRadius.circular(boxSize >= 36 ? 10 : 9),
        child: Icon(icon, size: boxSize / 2, color: AppColors.primary),
      );

  /// 이니셜 아바타 (연락처).
  factory InfoCardLeading.initial(String text) => InfoCardLeading._(
        size: 34,
        background: AppColors.primary.withValues(alpha: 0.12),
        radius: BorderRadius.circular(17),
        child: Text(
          text.isEmpty ? '' : text.characters.first,
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: child,
    );
  }
}

/// 흰색 라운드 카드 안에 행을 담고 사이에 1px 구분선을 넣는 컨테이너.
class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}
