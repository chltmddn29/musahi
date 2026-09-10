import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class SafetyContactPage extends StatelessWidget {
  const SafetyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBar: CustomAppBar(title: '안전 연락처 관리', icon: false),
      child: Center(child: Text('안전 연락처 관리 페이지')),
    );
  }
}
