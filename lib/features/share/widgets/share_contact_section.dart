import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'share_section_title.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:musahi/core/l10n/data_labels.dart';

class ShareContactSection extends StatelessWidget {
  final List<SafetyContact> contacts;

  const ShareContactSection({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShareSectionTitle(l10n.shareContactsTitle),
        const SizedBox(height: 10),
        if (contacts.isEmpty)
          InfoCard(
            title: l10n.shareContactsEmpty,
            caption: l10n.shareContactsEmptyCaption,
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
              caption: relationLabel(l10n, contacts[index].relation),
            ),
          ],
      ],
    );
  }
}
