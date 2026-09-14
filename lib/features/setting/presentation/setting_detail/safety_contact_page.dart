import 'package:flutter/material.dart';
import 'package:musahi/core/utils/category_selector.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class SafetyContactPage extends StatefulWidget {
  const SafetyContactPage({super.key});

  @override
  State<SafetyContactPage> createState() => _SafetyContactPageState();
}

class _SafetyContactPageState extends State<SafetyContactPage> {
  static const String allCategory = '전체';
  final List<String> category = [allCategory, '가족', '친구', '지인', '기타'];
  String selectedCategory = allCategory;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '안전 연락처 관리', icon: false),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CategorySelector(
              categories: category,
              selectedCategory: selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => selectedCategory = cat),
              height: 50,
              spacing: 10,
            ),
          ),
        ],
      ),
    );
  }
}
