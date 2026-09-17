import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/main.dart';

class _NonlinearScaler extends TextScaler {
  const _NonlinearScaler();

  @override
  double scale(double fontSize) =>
      fontSize < 20 ? fontSize * 2 : fontSize * 1.5;

  @override
  double get textScaleFactor => 2;
}

void main() {
  setUp(() => textSizeStep.value = 1);
  tearDown(() => textSizeStep.value = 1);

  test('preserves nonlinear platform scaling at every app size', () {
    const platform = _NonlinearScaler();
    for (var step = 0; step < textSizeStepLabels.length; step++) {
      final scaler = composeTextScaler(platform, step);
      for (final fontSize in [12.0, 24.0, 48.0]) {
        expect(
          scaler.scale(fontSize),
          platform.scale(fontSize) * textScaleForStep(step),
        );
      }
    }
  });

  testWidgets('MediaQuery textScaler follows textSizeStep', (tester) async {
    late BuildContext capturedContext;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          final app = const MyApp().build(context) as MaterialApp;
          return app.builder!(context, child);
        },
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const Text('sample');
          },
        ),
      ),
    );

    expect(MediaQuery.textScalerOf(capturedContext).scale(10), 20);

    textSizeStep.value = 3;
    await tester.pump();
    expect(
      MediaQuery.textScalerOf(capturedContext).scale(10),
      closeTo(20 * (26 / 17), 0.001),
    );

    textSizeStep.value = 0;
    await tester.pump();
    expect(
      MediaQuery.textScalerOf(capturedContext).scale(10),
      closeTo(20 * (14 / 17), 0.001),
    );

    textSizeStep.value = 1;
    await tester.pump();
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    await tester.pump();
    expect(MediaQuery.textScalerOf(capturedContext).scale(10), 30);
  });
}
