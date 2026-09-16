import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/settings/text_size_settings.dart';

void main() {
  testWidgets('MediaQuery textScaler follows textSizeStep', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return ValueListenableBuilder<int>(
            valueListenable: textSizeStep,
            builder: (context, step, _) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScaleForStep(step))),
                child: child!,
              );
            },
          );
        },
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Text('sample');
          },
        ),
      ),
    );

    expect(MediaQuery.textScalerOf(capturedContext).scale(10), 10);

    textSizeStep.value = 3;
    await tester.pump();
    expect(
      MediaQuery.textScalerOf(capturedContext).scale(10),
      closeTo(10 * (26 / 17), 0.001),
    );

    textSizeStep.value = 0;
    await tester.pump();
    expect(
      MediaQuery.textScalerOf(capturedContext).scale(10),
      closeTo(10 * (14 / 17), 0.001),
    );

    textSizeStep.value = 1;
    await tester.pump();
  });
}
