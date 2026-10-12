import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/custom_text_field.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key, this.editing});

  /// 수정 대상 연락처. null이면 새 연락처 추가 모드.
  final SafetyContact? editing;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  static const List<String> _relations = ['가족', '친구', '지인', '기타'];

  bool get _isEditing => widget.editing != null;

  late final _nameController = TextEditingController(
    text: widget.editing?.name,
  );
  late final _phoneController = TextEditingController(
    text: widget.editing?.phone,
  );
  late String _relation = widget.editing?.relation ?? _relations.first;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final contact = SafetyContact(
      id:
          widget.editing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      phone: _phoneController.text.trim(),
      relation: _relation,
    );
    if (_isEditing) {
      SafetyContactStore.instance.update(contact);
    } else {
      SafetyContactStore.instance.add(contact);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name 연락처를 ${_isEditing ? '수정' : '추가'}했습니다.')),
    );
    context.pop();
  }

  static TextEditingValue _formatPhoneNumber(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    String formatted;
    if (limited.length <= 3) {
      formatted = limited;
    } else if (limited.length <= 7) {
      formatted = '${limited.substring(0, 3)}-${limited.substring(3)}';
    } else {
      final midEnd = limited.length == 11 ? 7 : limited.length - 4;
      formatted =
          '${limited.substring(0, 3)}-${limited.substring(3, midEnd)}-${limited.substring(midEnd)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(title: _isEditing ? '연락처 수정' : '연락처 추가', icon: true),
      child: ListenableBuilder(
        listenable: Listenable.merge([_nameController, _phoneController]),
        builder: (context, _) {
          final canSubmit =
              _nameController.text.trim().length >= 2 &&
              RegExp(
                r'^\d{3}-\d{3,4}-\d{4}$',
              ).hasMatch(_phoneController.text.trim());
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  label: '이름',
                  hintText: '이름을 입력하세요',
                  controller: _nameController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  inputFormatters: [
                    const TextInputFormatter.withFunction(
                      _formatPhoneNumber,
                    ),
                  ],
                  label: '전화번호',
                  hintText: '010-0000-0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                const Text('관계', style: AppTextStyles.cardTitle),
                const SizedBox(height: 10),
                CategorySelector(
                  categories: _relations,
                  selectedCategory: _relation,
                  onCategorySelected: (value) =>
                      setState(() => _relation = value),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: canSubmit ? _submit : null,
                    child: _isEditing ? '수정' : '추가',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
