import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';
import 'package:musahi/features/disaster/repository/disaster_repository.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:musahi/core/l10n/data_labels.dart';

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

  /// 카테고리 변경 setState마다 Firestore 구독을 새로 열지 않도록 한 번만 만든다.
  late final Stream<List<DisasterMessage>> _messages = DisasterRepository
      .instance
      .watchMessage(limit: 50);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BaseScaffold(
      appBar: CustomAppBar(title: l10n.infoTitle, icon: false),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: CategorySelector(
              categories: category,
              selectedCategory: selectedCategory,
              labelOf: (category) => disasterCategoryLabel(l10n, category),
              onCategorySelected: (cat) =>
                  setState(() => selectedCategory = cat),
              pinFirst: true,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder(
              stream: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.infoLoadFailed));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allItems = snapshot.data!;
                final items = switch (selectedCategory) {
                  allCategory => allItems,
                  etcCategory =>
                    allItems
                        .where(
                          (e) =>
                              e.category == etcCategory ||
                              !category.contains(e.category),
                        )
                        .toList(),
                  _ =>
                    allItems
                        .where((e) => e.category == selectedCategory)
                        .toList(),
                };
                if (items.isEmpty) {
                  return Center(child: Text(l10n.infoEmpty));
                }
                return ListView.separated(
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    return InfoCard.alert(
                      title: item.title,
                      severity: item.severity,
                      time: item.createdAt,
                      onTap: () => context.push('/info/detail', extra: item),
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
