import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'share_section_title.dart';

class ShareContactSection extends StatelessWidget {
  final List<SafetyContact> contacts;

  const ShareContactSection({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ShareSectionTitle('등록된 안전 연락처'),
        const SizedBox(height: 10),
        if (contacts.isEmpty)
          InfoCard(
            title: '등록된 안전 연락처가 없습니다',
            caption: '연락처를 추가해 안전 상태를 공유할 준비를 해 주세요.',
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
            onTap: () => context.push('/setting/contacts/add'),
          )
        else
          for (var index = 0; index < contacts.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            InfoCard(
              key: ValueKey(contacts[index].id),
              leading: InfoCardLeading.initial(contacts[index].name),
              title: contacts[index].name,
              caption: contacts[index].relation,
            ),
          ],
      ],
    );
  }
}
