import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';
import 'package:musahi/features/guide/widgets/guide_step_list.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:musahi/core/l10n/data_labels.dart';

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
    final l10n = AppLocalizations.of(context);
    return BaseScaffold(
      appBar: CustomAppBar(
        title: l10n.guideTitle(disasterCategoryLabel(l10n, selected.category)),
        icon: false,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CategorySelector(
            categories: [for (final g in DisasterGuide.all) g.category],
            selectedCategory: selected.category,
            labelOf: (category) => disasterCategoryLabel(l10n, category),
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
