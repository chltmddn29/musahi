import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';
import 'package:musahi/features/guide/widgets/guide_step_list.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:musahi/core/l10n/data_labels.dart';

/// 재난문자에서 여는 행동요령. 탭 밖에 쌓아 뒤로가기로 돌아간다.
class GuideDetailPage extends StatelessWidget {
  final DisasterGuide guide;

  /// 재난 발생 지역. 대피소 버튼이 이 지역 대피소를 보여준다.
  final String? disasterRegion;

  const GuideDetailPage({super.key, required this.guide, this.disasterRegion});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BaseScaffold(
      appBar: CustomAppBar(
        title: l10n.guideTitle(disasterCategoryLabel(l10n, guide.category)),
      ),
      child: SafeArea(
        top: false,
        child: GuideStepList(
          guide: guide,
          onShelterPressed: () =>
              context.push('/disaster-shelters', extra: disasterRegion),
        ),
      ),
    );
  }
}
