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
      child: category,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      return SizedBox(height: height, child: scrollableList);
    }

    return SizedBox(
      height: height,
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
