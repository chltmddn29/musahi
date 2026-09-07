import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBar: CustomAppBar(title: '행동요령', icon: false),
      child: Center(child: Text('재난 행동요령 페이지')),
    );
  }
}
