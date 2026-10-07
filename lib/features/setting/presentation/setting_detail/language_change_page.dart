import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class LanguageChangePage extends StatelessWidget {
  const LanguageChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '언어 설정', icon: true),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.07,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text('한국어'), trailing: Icon(Icons.check)),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('현재 한국어만 지원합니다.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
