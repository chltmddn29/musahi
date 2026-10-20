import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/share/share_complete_page.dart';
import 'package:musahi/features/share/widgets/share_message_editor.dart';
import 'package:musahi/features/share/widgets/share_contact_section.dart';
import 'package:musahi/features/share/widgets/share_message_section.dart';
import 'package:musahi/l10n/app_localizations.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  /// null이면 현재 언어의 기본 메시지를 쓴다.
  String? _message;
  bool _isPreviewOpen = false;

  Future<void> _editMessage() async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => ShareMessageEditor(
        initialMessage:
            _message ?? AppLocalizations.of(context).shareDefaultMessage,
      ),
    );
    if (!mounted || message == null) return;
    setState(() => _message = message);
  }

  Future<void> _openPreview(List<SafetyContact> contacts) async {
    if (_isPreviewOpen || contacts.isEmpty) return;
    setState(() => _isPreviewOpen = true);
    try {
      await context.push<void>(
        '/share/complete',
        extra: SafetySharePreview(
          contactNames: contacts.map((contact) => contact.name),
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPreviewOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BaseScaffold(
      appBar: CustomAppBar(title: l10n.shareTitle, icon: false),
      child: ValueListenableBuilder<List<SafetyContact>>(
        valueListenable: SafetyContactStore.instance.contacts,
        builder: (context, contacts, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShareContactSection(contacts: contacts),
                    const SizedBox(height: 24),
                    ShareMessageSection(
                      message: _message ?? l10n.shareDefaultMessage,
                      onEdit: _editMessage,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CaptionText(
                      l10n.sharePreviewNotice,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: contacts.isEmpty || _isPreviewOpen
                          ? null
                          : () => _openPreview(contacts),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        padding: const EdgeInsets.all(15),
                        textStyle: AppTextStyles.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined, size: 17),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.shareButton,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
