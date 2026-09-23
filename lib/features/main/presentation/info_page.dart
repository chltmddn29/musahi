import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/repository/disaster_repository.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  static const String allCategory = '전체';
  static const String etcCategory = '기타';
  final List<String> category = [
    allCategory,
    '폭염',
    '지진',
    '태풍',
    '호우',
    etcCategory,
  ];
  String selectedCategory = allCategory;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '재난 정보', icon: false),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CategorySelector(
              categories: category,
              selectedCategory: selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => selectedCategory = cat),
              pinFirst: true,
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
                final items = switch (selectedCategory) {
                  allCategory => allItems,
                  etcCategory => allItems
                      .where((e) => !category.contains(e.category))
                      .toList(),
                  _ => allItems
                      .where((e) => e.category == selectedCategory)
                      .toList(),
                };
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
                      onTap: () =>
                          context.push('/info/detail', extra: item),
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
