import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class RegionManagePage extends StatelessWidget {
  const RegionManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBar: CustomAppBar(title: '관심지역 관리', icon: false),
      child: Center(child: Text('관심지역 관리 페이지')),
    );
  }
}
