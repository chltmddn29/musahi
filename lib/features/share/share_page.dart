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
                    _ContactSection(contacts: contacts),
                    const SizedBox(height: 24),
                    _MessageSection(message: _message, onEdit: _editMessage),
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

class _ContactSection extends StatelessWidget {
  final List<SafetyContact> contacts;

  const _ContactSection({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('등록된 안전 연락처'),
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

class _MessageSection extends StatelessWidget {
  final String message;
  final VoidCallback onEdit;

  const _MessageSection({required this.message, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('자동 생성 메시지')),
            IconButton(
              onPressed: onEdit,
              tooltip: '메시지 수정',
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.muted,
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            color: AppColors.messageSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
