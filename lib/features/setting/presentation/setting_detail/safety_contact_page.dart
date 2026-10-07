import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/custom_text_field.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';

class SafetyContactPage extends StatefulWidget {
  const SafetyContactPage({super.key});

  @override
  State<SafetyContactPage> createState() => _SafetyContactPageState();
}

class _SafetyContactPageState extends State<SafetyContactPage> {
  static const String _allCategory = '전체';
  static const List<String> _categories = [
    _allCategory,
    '가족',
    '친구',
    '지인',
    '기타',
  ];

  final _searchController = TextEditingController();
  String _selectedCategory = _allCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SafetyContact> _filter(List<SafetyContact> contacts) {
    final query = _searchController.text.trim();
    return contacts.where((contact) {
      final matchesCategory =
          _selectedCategory == _allCategory ||
          contact.relation == _selectedCategory;
      final matchesQuery = query.isEmpty || contact.name.contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '안전 연락처 관리', icon: true),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CategorySelector(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
              height: 40,
              spacing: 10,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          CustomTextField(
            controller: _searchController,
            hintText: '연락처를 입력하세요',
            prefixIcon: const Icon(Icons.search),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ValueListenableBuilder<List<SafetyContact>>(
              valueListenable: SafetyContactStore.instance.contacts,
              builder: (context, contacts, _) {
                final filtered = _filter(contacts);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      '등록된 연락처가 없습니다',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: SettingsGroup(
                    children: [
                      for (final contact in filtered)
                        InfoCard(
                          flat: true,
                          leading: InfoCardLeading.initial(contact.name),
                          title: contact.name,
                          caption: '${contact.relation} · ${contact.phone}',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => context.push(
                                  '/setting/contacts/add',
                                  extra: contact,
                                ),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.muted,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () =>
                                    SafetyContactStore.instance.remove(contact),
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.muted,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () => context.push('/setting/contacts/add'),
              child: '연락처 추가',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
