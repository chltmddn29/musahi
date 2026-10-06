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

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  String _message = '저는 지금 안전합니다. 걱정하지 마세요.';
  bool _isPreviewOpen = false;

  Future<void> _editMessage() async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => ShareMessageEditor(initialMessage: _message),
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
    return BaseScaffold(
      appBar: const CustomAppBar(title: '안전 상태 공유', icon: false),
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
                      message: _message,
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
                    const CaptionText(
                      '현재는 미리보기이며 실제 메시지는 전송되지 않습니다.',
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_outlined, size: 17),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '저는 안전합니다 (공유하기)',
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
