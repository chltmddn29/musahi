import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';
import 'package:musahi/features/guide/widgets/guide_step_list.dart';

/// 행동요령 탭. 재난 유형을 골라 행동요령을 본다.
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  DisasterGuide selected = DisasterGuide.all.first;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(title: '${selected.category} 행동요령', icon: false),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CategorySelector(
            categories: [for (final g in DisasterGuide.all) g.category],
            selectedCategory: selected.category,
            onCategorySelected: (category) =>
                setState(() => selected = DisasterGuide.of(category)!),
          ),
          Expanded(
            child: GuideStepList(
              guide: selected,
              onShelterPressed: () => context.go('/shelter'),
            ),
          ),
        ],
      ),
    );
  }
}
