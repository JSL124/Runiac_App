// Focused coverage for curated haptic moments: run lifecycle, XP/level-up
// reveal, plan completion, challenge-earned ceremony, and the save-success
// overlay. Each moment is asserted through a recording fake injected via
// `RuniacHapticsScope`, never against the real platform channel.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/haptics/runiac_haptics.dart';
import 'package:runiac_app/core/haptics/runiac_haptics_scope.dart';
import 'package:runiac_app/core/widgets/runiac_success_check_overlay.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_enums.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_result_ceremony.dart';
import 'package:runiac_app/features/home/presentation/plan_completion_ceremony.dart';
import 'package:runiac_app/features/run/domain/models/xp_update_display_model.dart';
import 'package:runiac_app/features/run/presentation/run_active_screen.dart';
import 'package:runiac_app/features/run/presentation/xp_update_screen.dart';

/// Records every haptic method invoked, in call order, so tests can assert
/// on which curated moments fired without depending on a real platform
/// channel.
class RecordingRuniacHaptics implements RuniacHaptics {
  final List<String> calls = <String>[];
  bool enabled = true;

  @override
  void selection() => calls.add('selection');

  @override
  void impactLight() => calls.add('impactLight');

  @override
  void impactMedium() => calls.add('impactMedium');

  @override
  void impactHeavy() => calls.add('impactHeavy');

  @override
  void error() => calls.add('error');

  @override
  void setEnabled(bool value) => enabled = value;
}

Widget _wrap(RecordingRuniacHaptics recorder, Widget child) {
  return RuniacHapticsScope(
    haptics: recorder,
    child: MaterialApp(home: child),
  );
}

void main() {
  group('save-success overlay', () {
    testWidgets('fires impactMedium when shown', (tester) async {
      final recorder = RecordingRuniacHaptics();
      await tester.pumpWidget(
        _wrap(
          recorder,
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showRuniacSuccessCheckOverlay(context),
                child: const Text('save'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('save'));
      await tester.pump();

      expect(recorder.calls, contains('impactMedium'));
    });

    testWidgets('still fires impactMedium under reduced motion', (
      tester,
    ) async {
      final recorder = RecordingRuniacHaptics();
      await tester.pumpWidget(
        RuniacHapticsScope(
          haptics: recorder,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: true),
                  child: Scaffold(
                    body: Builder(
                      builder: (innerContext) => ElevatedButton(
                        onPressed: () =>
                            showRuniacSuccessCheckOverlay(innerContext),
                        child: const Text('save'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('save'));
      await tester.pump();

      expect(recorder.calls, contains('impactMedium'));
    });
  });

  group('XP update reveal', () {
    const baseModel = XpUpdateDisplayModel(
      runnerName: 'Ada',
      earnedXpLabel: '+75 XP',
      totalXpLabel: '1,240 XP',
      levelLabel: '4',
      nextLevelLabel: '5',
      progressTargetLabel: 'Progress to Level 5',
      xpRemainingLabel: '260 XP to Level 5',
      previousProgressFraction: 0.30,
      currentProgressFraction: 0.62,
      streakChangeLabel: '3 → 4 days',
      streakNote: 'Keep it going',
      didLevelUp: false,
      xpAwardState: XpAwardState.awarded,
      heroMessage: 'Earned from this run',
      earnedXp: 75,
      totalXp: 1240,
      previousTotalXp: 1165,
      level: 4,
      previousLevel: 4,
      streakCount: 4,
      previousStreakCount: 3,
    );

    testWidgets('non level-up reveal fires impactMedium only', (
      tester,
    ) async {
      final recorder = RecordingRuniacHaptics();
      await tester.pumpWidget(
        _wrap(
          recorder,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const XpUpdateScreen(model: baseModel),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(recorder.calls, contains('impactMedium'));
      expect(recorder.calls, isNot(contains('impactHeavy')));
    });

    testWidgets('level-up reveal fires impactHeavy, not impactMedium', (
      tester,
    ) async {
      final recorder = RecordingRuniacHaptics();
      final levelUpModel = XpUpdateDisplayModel(
        runnerName: baseModel.runnerName,
        earnedXpLabel: baseModel.earnedXpLabel,
        totalXpLabel: baseModel.totalXpLabel,
        levelLabel: baseModel.levelLabel,
        nextLevelLabel: baseModel.nextLevelLabel,
        progressTargetLabel: baseModel.progressTargetLabel,
        xpRemainingLabel: baseModel.xpRemainingLabel,
        previousProgressFraction: baseModel.previousProgressFraction,
        currentProgressFraction: baseModel.currentProgressFraction,
        streakChangeLabel: baseModel.streakChangeLabel,
        streakNote: baseModel.streakNote,
        didLevelUp: true,
        xpAwardState: baseModel.xpAwardState,
        heroMessage: 'You reached Level 5. Keep it up.',
        earnedXp: baseModel.earnedXp,
        totalXp: baseModel.totalXp,
        previousTotalXp: baseModel.previousTotalXp,
        level: baseModel.level,
        previousLevel: baseModel.previousLevel,
        streakCount: baseModel.streakCount,
        previousStreakCount: baseModel.previousStreakCount,
      );

      await tester.pumpWidget(
        _wrap(
          recorder,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: XpUpdateScreen(model: levelUpModel),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(recorder.calls, contains('impactHeavy'));
      expect(recorder.calls, isNot(contains('impactMedium')));
    });
  });

  group('plan completion ceremony', () {
    testWidgets('fires impactHeavy once on reveal', (tester) async {
      final recorder = RecordingRuniacHaptics();
      await tester.pumpWidget(
        _wrap(
          recorder,
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showPlanCompletionCeremony(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(recorder.calls.where((call) => call == 'impactHeavy'), hasLength(1));

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump(const Duration(milliseconds: 260));

      // Still exactly one, even after the gauge-fill reveal completes.
      expect(recorder.calls.where((call) => call == 'impactHeavy'), hasLength(1));
    });
  });

  group('challenge earned ceremony', () {
    testWidgets('fires impactHeavy on reveal', (tester) async {
      final recorder = RecordingRuniacHaptics();
      await tester.pumpWidget(
        _wrap(recorder, const ChallengeBadgeCeremony(tierId: ChallengeTierId.k10)),
      );

      // The ceremony runs a continuous ambient/fireworks loop that never
      // settles, so drive a bounded number of frames instead of
      // `pumpAndSettle`.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(recorder.calls, contains('impactHeavy'));
    });
  });

  group('run lifecycle', () {
    testWidgets(
      'start fires impactMedium and pause/resume fire impactLight',
      (tester) async {
        final recorder = RecordingRuniacHaptics();
        await tester.pumpWidget(_wrap(recorder, const RunActiveScreen()));
        await tester.pump();

        expect(recorder.calls, contains('impactMedium'));
        final startCalls = recorder.calls.length;

        await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
        await tester.pump();

        expect(recorder.calls.skip(startCalls), contains('impactLight'));
        final afterPauseCalls = recorder.calls.length;

        await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
        await tester.pump();

        expect(recorder.calls.skip(afterPauseCalls), contains('impactLight'));
      },
    );
  });
}
