import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';

/// 카테고리 필터용 가로 스크롤 버튼 목록.
///
/// [pinFirst]가 true면 첫 번째 카테고리(보통 '전체')를 왼쪽에 고정하고
/// 나머지 카테고리만 스크롤되도록 배치한다.
class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool pinFirst;
  final double height;
  final double spacing;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.pinFirst = false,
    this.height = 40,
    this.spacing = 15,
  });

  Widget _categoryButton(String category) {
    final isSelected = category == selectedCategory;
    return CustomElevatedButton(
      onPressed: () => onCategorySelected(category),
      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
      foregroundColor: isSelected ? AppColors.surface : AppColors.primary,
      // 흰 배경 버튼이 화면 배경과 거의 같은 색이라 스크롤 끝에서 잘릴 때
      // 경계가 안 보이고 뚝 끊긴 것처럼 보였다. 연한 테두리를 둘러서
      // 잘려도 "카드가 계속 이어진다"는 게 분명히 보이도록 한다.
      borderColor: isSelected
          ? null
          : AppColors.primary.withValues(alpha: 0.25),
      child: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 1.5);
    final resolvedHeight = height * textScale;

    final scrollableCategories = pinFirst
        ? categories.skip(1).toList()
        : categories;

    final scrollableList = ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) =>
          _categoryButton(scrollableCategories[index]),
      separatorBuilder: (context, index) => SizedBox(width: spacing),
      itemCount: scrollableCategories.length,
    );

    if (!pinFirst || categories.isEmpty) {
      return SizedBox(height: resolvedHeight, child: scrollableList);
    }

    return SizedBox(
      height: resolvedHeight,
      child: Row(
        children: [
          _categoryButton(categories.first),
          SizedBox(width: spacing),
          Expanded(child: scrollableList),
        ],
      ),
    );
  }
}
