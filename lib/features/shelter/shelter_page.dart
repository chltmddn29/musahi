import 'package:flutter/material.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class ShelterPage extends StatelessWidget {
  const ShelterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBar: CustomAppBar(title: '위치', icon: false),
      child: Center(child: Text('대피소 위치 페이지')),
    );
  }
}
