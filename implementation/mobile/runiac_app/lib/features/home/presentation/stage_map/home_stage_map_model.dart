import '../../../plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import '../../../plan/presentation/current_session_generated_plan.dart'
    show isGeneratedPlanSession;
import 'home_stage_background_sequence.dart';

/// Number of day slots rendered per week on the stage map.
const int kHomeStageDaysPerWeek = 7;

enum HomeStageStoneKind { run, rest }

/// Display-only progress state for a stage stone.
///
/// `completed`/`current` for run stones are derived strictly from
/// backend-owned completed scheduled-workout ids; no XP/streak/level value is
/// computed here. Rest-stone states are purely cosmetic dimming based on
/// position and carry no trusted meaning.
enum HomeStageStoneState { completed, current, future }

class HomeStageStone {
  const HomeStageStone({
    required this.weekNumber,
    required this.dayIndex,
    required this.kind,
    required this.state,
    this.scheduledWorkoutId,
    this.workoutTitle,
  });

  final int weekNumber;
  final int dayIndex;
  final HomeStageStoneKind kind;
  final HomeStageStoneState state;
  final String? scheduledWorkoutId;
  final String? workoutTitle;

  bool get isRun => kind == HomeStageStoneKind.run;
  bool get isCurrent => state == HomeStageStoneState.current;
  bool get isCompleted => state == HomeStageStoneState.completed;
}

class HomeStageWeekSection {
  const HomeStageWeekSection({
    required this.weekNumber,
    required this.backgroundAsset,
    required this.stones,
  });

  final int weekNumber;
  final String backgroundAsset;

  /// Always [kHomeStageDaysPerWeek] stones, ordered day 1 (bottom) to day 7.
  final List<HomeStageStone> stones;
}

class HomeStageMapModel {
  const HomeStageMapModel({
    required this.sections,
    required this.currentWeekIndex,
    required this.todayDayIndex,
    required this.characterDayIndex,
    required this.currentStageId,
  });

  /// Ordered bottom-up: index 0 is plan week 1 (rendered at the bottom).
  final List<HomeStageWeekSection> sections;

  /// Section index of the active week, or null when there are no stages.
  final int? currentWeekIndex;

  /// Day index (within the active week) of the next uncompleted eligible run
  /// stone that should pulse as "today", or null when the week has none.
  final int? todayDayIndex;

  /// Day index (within the active week) where the guide character stands.
  final int? characterDayIndex;

  /// Stable identifier of the character's stage (`"weekIndex:dayIndex"`), used
  /// to detect forward progress between sessions. Null when there are no
  /// stages.
  final String? currentStageId;

  bool get hasStages => sections.isNotEmpty;

  static String stageId(int weekIndex, int dayIndex) => '$weekIndex:$dayIndex';
}

/// Rebuilds the scheduled-workout id used by the generated-plan display layer.
///
/// This mirrors the id scheme used when completed workouts are recorded, so a
/// run stone can be matched against backend-owned completed ids.
String homeStageScheduledWorkoutId({
  required int weekNumber,
  required String dayLabel,
  required String title,
}) {
  final titleSlug = title
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-+$'), '');
  final suffix = titleSlug.isEmpty ? 'workout' : titleSlug;
  return 'week-$weekNumber-${dayLabel.toLowerCase()}-$suffix';
}

class _RawStone {
  const _RawStone({
    required this.kind,
    required this.completed,
    required this.dayLabel,
    required this.scheduledWorkoutId,
    required this.workoutTitle,
  });

  final HomeStageStoneKind kind;
  final bool completed;
  final String? dayLabel;
  final String? scheduledWorkoutId;
  final String? workoutTitle;
}

/// Pure builder that turns a plan + backend completion set into a renderable
/// stage map. No trusted value is computed; run completion comes only from
/// [completedScheduledWorkoutIds].
HomeStageMapModel buildHomeStageMapModel({
  required BeginnerAdaptivePlanSnapshot plan,
  required Set<String> completedScheduledWorkoutIds,
  required int activeWeekNumber,
  required List<String> backgroundSequence,
}) {
  if (plan.weeks.isEmpty) {
    return const HomeStageMapModel(
      sections: <HomeStageWeekSection>[],
      currentWeekIndex: null,
      todayDayIndex: null,
      characterDayIndex: null,
      currentStageId: null,
    );
  }

  final rawByWeek = <List<_RawStone>>[];
  for (var w = 0; w < plan.weeks.length; w++) {
    final week = plan.weeks[w];
    final rawStones = <_RawStone>[];
    for (var d = 0; d < kHomeStageDaysPerWeek; d++) {
      if (d < week.workouts.length) {
        final workout = week.workouts[d];
        if (isGeneratedPlanSession(workout)) {
          final id = homeStageScheduledWorkoutId(
            weekNumber: week.weekNumber,
            dayLabel: workout.dayLabel,
            title: workout.title,
          );
          rawStones.add(
            _RawStone(
              kind: HomeStageStoneKind.run,
              completed: completedScheduledWorkoutIds.contains(id),
              dayLabel: workout.dayLabel,
              scheduledWorkoutId: id,
              workoutTitle: workout.title,
            ),
          );
          continue;
        }
      }
      rawStones.add(
        const _RawStone(
          kind: HomeStageStoneKind.rest,
          completed: false,
          dayLabel: null,
          scheduledWorkoutId: null,
          workoutTitle: null,
        ),
      );
    }
    rawByWeek.add(rawStones);
  }

  // Resolve the active week section index.
  var currentWeekIndex = plan.weeks.indexWhere(
    (week) => week.weekNumber == activeWeekNumber,
  );
  if (currentWeekIndex < 0) {
    currentWeekIndex = 0;
  }

  final activeRaw = rawByWeek[currentWeekIndex];
  int? todayDayIndex;
  int? characterDayIndex;
  int? lastRunIndex;
  for (var d = 0; d < activeRaw.length; d++) {
    final stone = activeRaw[d];
    if (stone.kind != HomeStageStoneKind.run) {
      continue;
    }
    lastRunIndex = d;
    if (!stone.completed && todayDayIndex == null) {
      todayDayIndex = d;
    }
  }
  characterDayIndex = todayDayIndex ?? lastRunIndex ?? 0;

  final characterOrdinal =
      currentWeekIndex * kHomeStageDaysPerWeek + characterDayIndex;

  final sections = <HomeStageWeekSection>[];
  for (var w = 0; w < plan.weeks.length; w++) {
    final week = plan.weeks[w];
    final background = backgroundSequence.length > w
        ? backgroundSequence[w]
        : (backgroundSequence.isEmpty
              ? kHomeStageBackgroundAssets[w % kHomeStageBackgroundAssets.length]
              : backgroundSequence[w % backgroundSequence.length]);
    final raw = rawByWeek[w];
    final stones = <HomeStageStone>[];
    for (var d = 0; d < raw.length; d++) {
      final stone = raw[d];
      final HomeStageStoneState state;
      if (stone.kind == HomeStageStoneKind.run) {
        if (stone.completed) {
          state = HomeStageStoneState.completed;
        } else if (w == currentWeekIndex && d == todayDayIndex) {
          state = HomeStageStoneState.current;
        } else {
          state = HomeStageStoneState.future;
        }
      } else {
        final ordinal = w * kHomeStageDaysPerWeek + d;
        state = ordinal < characterOrdinal
            ? HomeStageStoneState.completed
            : HomeStageStoneState.future;
      }
      stones.add(
        HomeStageStone(
          weekNumber: week.weekNumber,
          dayIndex: d,
          kind: stone.kind,
          state: state,
          scheduledWorkoutId: stone.scheduledWorkoutId,
          workoutTitle: stone.workoutTitle,
        ),
      );
    }
    sections.add(
      HomeStageWeekSection(
        weekNumber: week.weekNumber,
        backgroundAsset: background,
        stones: stones,
      ),
    );
  }

  return HomeStageMapModel(
    sections: sections,
    currentWeekIndex: currentWeekIndex,
    todayDayIndex: todayDayIndex,
    characterDayIndex: characterDayIndex,
    currentStageId: HomeStageMapModel.stageId(
      currentWeekIndex,
      characterDayIndex,
    ),
  );
}
