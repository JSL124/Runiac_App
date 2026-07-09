import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_background_sequence.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map_model.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/plan_family_test_drafts.dart';

BeginnerAdaptivePlanSnapshot _plan() {
  return const BeginnerAdaptivePlanGenerator().generate(
    planFamilyPerformanceDraft(
      goal: OnboardingGoal.tenK,
      style: OnboardingPlanStyle.performanceFocused,
      days: const [
        OnboardingPreferredDay.mon,
        OnboardingPreferredDay.tue,
        OnboardingPreferredDay.wed,
        OnboardingPreferredDay.thu,
      ],
    ),
  );
}

String _idFor(BeginnerAdaptivePlanWeek week, BeginnerAdaptiveWorkout workout) {
  return homeStageScheduledWorkoutId(
    weekNumber: week.weekNumber,
    dayLabel: workout.dayLabel,
    title: workout.title,
  );
}

void main() {
  test('every section has exactly 7 stones padded with rest', () {
    final plan = _plan();
    final model = buildHomeStageMapModel(
      plan: plan,
      completedScheduledWorkoutIds: const <String>{},
      activeWeekNumber: plan.weeks.first.weekNumber,
      backgroundSequence: homeStageBackgroundSequence(
        planId: plan.id,
        weekCount: plan.weeks.length,
      ),
    );

    expect(model.sections, hasLength(plan.weeks.length));
    for (final section in model.sections) {
      expect(section.stones, hasLength(kHomeStageDaysPerWeek));
    }
  });

  test('run vs rest stones follow the workout kind and padding', () {
    final plan = _plan();
    final model = buildHomeStageMapModel(
      plan: plan,
      completedScheduledWorkoutIds: const <String>{},
      activeWeekNumber: plan.weeks.first.weekNumber,
      backgroundSequence: homeStageBackgroundSequence(
        planId: plan.id,
        weekCount: plan.weeks.length,
      ),
    );

    final week = plan.weeks.first;
    final section = model.sections.first;
    for (var d = 0; d < kHomeStageDaysPerWeek; d++) {
      final stone = section.stones[d];
      if (d < week.workouts.length) {
        final expectedRun = isGeneratedPlanSession(week.workouts[d]);
        expect(
          stone.kind,
          expectedRun ? HomeStageStoneKind.run : HomeStageStoneKind.rest,
        );
      } else {
        expect(stone.kind, HomeStageStoneKind.rest);
      }
    }
  });

  test('completed run stones come only from backend completed ids', () {
    final plan = _plan();
    final week = plan.weeks.first;
    final firstRun = week.workouts.firstWhere(isGeneratedPlanSession);
    final completedId = _idFor(week, firstRun);

    final model = buildHomeStageMapModel(
      plan: plan,
      completedScheduledWorkoutIds: {completedId},
      activeWeekNumber: week.weekNumber,
      backgroundSequence: homeStageBackgroundSequence(
        planId: plan.id,
        weekCount: plan.weeks.length,
      ),
    );

    final completedStone = model.sections.first.stones.firstWhere(
      (stone) => stone.scheduledWorkoutId == completedId,
    );
    expect(completedStone.state, HomeStageStoneState.completed);

    // Today is now the next uncompleted run after the completed one.
    final today = model.todayDayIndex;
    expect(today, isNotNull);
    final todayStone = model.sections.first.stones[today!];
    expect(todayStone.kind, HomeStageStoneKind.run);
    expect(todayStone.state, HomeStageStoneState.current);
    expect(todayStone.dayIndex, greaterThan(completedStone.dayIndex));
  });

  test('current stage is the first uncompleted run of the active week', () {
    final plan = _plan();
    final model = buildHomeStageMapModel(
      plan: plan,
      completedScheduledWorkoutIds: const <String>{},
      activeWeekNumber: plan.weeks.first.weekNumber,
      backgroundSequence: homeStageBackgroundSequence(
        planId: plan.id,
        weekCount: plan.weeks.length,
      ),
    );

    expect(model.currentWeekIndex, 0);
    final firstRunIndex = model.sections.first.stones
        .indexWhere((stone) => stone.isRun);
    expect(model.todayDayIndex, firstRunIndex);
    expect(model.characterDayIndex, firstRunIndex);
    expect(model.currentStageId, HomeStageMapModel.stageId(0, firstRunIndex));
  });

  test('empty-week plan produces no sections', () {
    final plan = _plan();
    final emptyPlan = BeginnerAdaptivePlanSnapshot(
      id: plan.id,
      title: plan.title,
      subtitle: plan.subtitle,
      planKind: plan.planKind,
      sourceLabel: plan.sourceLabel,
      durationWeeks: 0,
      safetyBand: plan.safetyBand,
      templateKind: plan.templateKind,
      family: plan.family,
      familyCategory: plan.familyCategory,
      familyReason: plan.familyReason,
      supportStyleLabel: plan.supportStyleLabel,
      weeklyFrequencyLabel: plan.weeklyFrequencyLabel,
      preferredScheduleLabel: plan.preferredScheduleLabel,
      sessionDurationLabel: plan.sessionDurationLabel,
      safetyNote: plan.safetyNote,
      weeks: const <BeginnerAdaptivePlanWeek>[],
    );

    final model = buildHomeStageMapModel(
      plan: emptyPlan,
      completedScheduledWorkoutIds: const <String>{},
      activeWeekNumber: 1,
      backgroundSequence: const <String>[],
    );
    expect(model.hasStages, isFalse);
    expect(model.currentStageId, isNull);
  });
}
