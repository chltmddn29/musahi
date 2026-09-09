import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/repository/disaster_repository.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  static const String allCategory = '전체';
  final List<String> category = [allCategory, '폭염', '지진', '태풍', '호우', '기타'];
  String selectedCategory = allCategory;

  Widget _categoryButton(String cat) {
    final isSelected = selectedCategory == cat;
    return CustomElevatedButton(
      onPressed: () => setState(() => selectedCategory = cat),
      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
      foregroundColor: isSelected ? AppColors.surface : AppColors.primary,
      child: cat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '재난 정보', icon: false),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  _categoryButton(allCategory),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, idx) {
                        return _categoryButton(category[idx + 1]);
                      },
                      separatorBuilder: (context, idx) =>
                          const SizedBox(width: 15),
                      itemCount: category.length - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder(
              stream: DisasterRepository.instance.watchMessage(limit: 50),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allItems = snapshot.data!;
                final items = selectedCategory == allCategory
                    ? allItems
                    : allItems
                          .where((e) => e.category == selectedCategory)
                          .toList();
                if (items.isEmpty) {
                  return const Center(child: Text('해당 카테고리의 정보가 없습니다.'));
                }
                return ListView.separated(
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    return InfoCard.alert(
                      title: item.title,
                      severity: item.severity,
                      time: item.createdAt,
                    );
                  },
                  separatorBuilder: (context, idx) =>
                      const SizedBox(height: 15),
                  itemCount: items.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
