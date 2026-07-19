import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/presentation/plan_completion_ceremony.dart';

Widget _harness({required bool reduceMotion}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPlanCompletionCeremony(context),
                child: const Text('open'),
              ),
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  testWidgets(
    'renders the barrier and close button, and reveals the message and '
    'second asset once the gauge finishes',
    (tester) async {
      await tester.pumpWidget(_harness(reduceMotion: false));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.widgetWithText(AnimatedOpacity, 'Plan Completed!'),
            )
            .opacity,
        0,
      );

      await tester.pump(const Duration(milliseconds: 1600));
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.widgetWithText(AnimatedOpacity, 'Plan Completed!'),
            )
            .opacity,
        1,
      );
      await tester.pump(const Duration(milliseconds: 260));
    },
  );

  testWidgets('tapping the close button dismisses the overlay', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(reduceMotion: false));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('reduced motion opens directly in the fully-revealed state', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(reduceMotion: true));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Completed!'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.widgetWithText(AnimatedOpacity, 'Plan Completed!'),
          )
          .opacity,
      1,
    );
  });
}
