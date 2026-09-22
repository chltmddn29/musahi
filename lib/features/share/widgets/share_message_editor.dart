import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';

class ShareMessageEditor extends StatefulWidget {
  final String initialMessage;

  const ShareMessageEditor({super.key, required this.initialMessage});

  @override
  State<ShareMessageEditor> createState() => _ShareMessageEditorState();
}

/// [InputDecoration.border] 하나만 주면 InputDecorator가 M3 기본값
/// (colorScheme.primary)으로 borderSide를 덮어쓴다. 색을 유지하려면
/// 상태별 border를 각각 지정해야 한다.
OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: color, width: width),
    );

class _ShareMessageEditorState extends State<ShareMessageEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialMessage);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('메시지 수정', style: AppTextStyles.titleMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 500,
                  style: AppTextStyles.bodyMedium,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    labelText: '안전 상태 메시지',
                    alignLabelWithHint: true,
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.muted,
                    ),
                    floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    enabledBorder: _border(AppColors.muted),
                    focusedBorder: _border(AppColors.primary, width: 2),
                    errorBorder: _border(AppColors.alertCritical),
                    focusedErrorBorder: _border(
                      AppColors.alertCritical,
                      width: 2,
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '공유할 메시지를 입력해 주세요.'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(onPressed: _save, child: '저장'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
