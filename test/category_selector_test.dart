import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/utils/category_selector.dart';

void main() {
  testWidgets('선택된 카테고리만 접근성 선택 상태로 전달된다', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategorySelector(
            categories: const ['전체', '폭염', '지진'],
            selectedCategory: '폭염',
            onCategorySelected: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('폭염')),
      matchesSemantics(
        label: '폭염',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        isFocusable: true,
        hasEnabledState: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('지진')),
      isNot(matchesSemantics(isSelected: true)),
    );
    handle.dispose();
  });
}
