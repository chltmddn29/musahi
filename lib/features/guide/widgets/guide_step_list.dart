import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';

/// 번호 카드로 나열한 행동요령 + 하단 "가까운 대피소 보기" 버튼.
/// 탭 화면([GuidePage])과 상세 화면([GuideDetailPage])이 함께 쓴다.
class GuideStepList extends StatelessWidget {
  final DisasterGuide guide;
  final VoidCallback onShelterPressed;

  const GuideStepList({
    super.key,
    required this.guide,
    required this.onShelterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: guide.steps.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final step = guide.steps[index];
              return InfoCard(
                leading: InfoCardLeading.number(index + 1),
                title: step.title,
                caption: step.description,
                crossAxisAlignment: CrossAxisAlignment.start,
              );
            },
          ),
        ),
        if (guide.needsShelter) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: onShelterPressed,
              child: '가까운 대피소 보기',
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
