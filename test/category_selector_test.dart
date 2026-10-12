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

  testWidgets('글자 배율이 커져도 목록 높이가 따라 늘어 글자가 잘리지 않는다', (tester) async {
    for (final scale in [1.0, 1.5, 2.5, 3.0]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: CategorySelector(
              categories: const ['전체', '폭염', '지진'],
              selectedCategory: '전체',
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      final listHeight = tester.getSize(find.byType(CategorySelector)).height;
      expect(listHeight, 40 * scale, reason: 'scale $scale');
      expect(
        tester.getSize(find.text('폭염')).height,
        lessThanOrEqualTo(listHeight),
        reason: 'scale $scale',
      );
      expect(tester.takeException(), isNull, reason: 'scale $scale');
    }
  });
}
