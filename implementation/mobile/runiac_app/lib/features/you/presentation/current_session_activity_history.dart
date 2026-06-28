import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../run/domain/models/complete_run_result.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import '../../run/domain/models/run_summary_snapshot.dart';
import 'data/activity_history_demo_snapshots.dart';

class SessionCompletedRunActivity {
  const SessionCompletedRunActivity({
    required this.activityId,
    required this.display,
    required this.completionResult,
  });

  final String activityId;
  final RunActivityDisplayModel display;
  final CompleteRunResult completionResult;
}

class CurrentSessionActivityHistoryStore extends ChangeNotifier {
  CurrentSessionActivityHistoryStore({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<SessionCompletedRunActivity> _activities =
      <SessionCompletedRunActivity>[];

  UnmodifiableListView<SessionCompletedRunActivity> get activities {
    return UnmodifiableListView(_activities);
  }

  void registerCompletedRun(CompleteRunResult result) {
    final activity = SessionCompletedRunActivity(
      activityId: result.activityId,
      display: RunActivityDisplayModel(
        activityId: result.activityId,
        title: result.summary.title,
        timeAgoLabel: result.summary.dateTimeLabel,
        distanceLabel: '${result.summary.distanceKm} km',
        paceLabel: result.summary.avgPace,
        durationLabel: result.summary.duration,
        summary: result.summary,
        completionResult: result,
      ),
      completionResult: result,
    );

    _activities.removeWhere((item) => item.activityId == activity.activityId);
    _activities.insert(0, activity);
    notifyListeners();
  }

  List<RunActivityDisplayModel> recentRunsWithFallback(
    List<RunActivityDisplayModel> fallback, {
    int limit = 3,
  }) {
    final merged = <RunActivityDisplayModel>[
      for (final activity in _activities) activity.display,
      ...fallback,
    ];
    final seenIds = <String>{};
    final deduped = <RunActivityDisplayModel>[];

    for (final activity in merged) {
      final activityId = activity.activityId;
      if (activityId != null &&
          activityId.isNotEmpty &&
          !seenIds.add(activityId)) {
        continue;
      }
      deduped.add(activity);
      if (deduped.length == limit) {
        break;
      }
    }

    return deduped;
  }

  List<ActivityHistoryMonth> activityHistoryWithFallback(
    List<ActivityHistoryMonth> fallback,
  ) {
    if (_activities.isEmpty) {
      return fallback;
    }

    final sessionActivitiesByMonth = <String, List<RunActivityDisplayModel>>{};
    for (final activity in _activities) {
      final label = _monthLabelFor(activity.display.summary);
      sessionActivitiesByMonth
          .putIfAbsent(label, () => <RunActivityDisplayModel>[])
          .add(activity.display);
    }

    final merged = <ActivityHistoryMonth>[];
    final fallbackLabels = fallback.map((month) => month.label).toSet();

    for (final entry in sessionActivitiesByMonth.entries) {
      if (!fallbackLabels.contains(entry.key)) {
        merged.add(
          ActivityHistoryMonth(label: entry.key, activities: entry.value),
        );
      }
    }

    for (final month in fallback) {
      final sessionActivities = sessionActivitiesByMonth[month.label];
      if (sessionActivities == null) {
        merged.add(month);
        continue;
      }

      merged.add(
        ActivityHistoryMonth(
          label: month.label,
          activities: <RunActivityDisplayModel>[
            ...sessionActivities,
            ...month.activities,
          ],
        ),
      );
    }

    return merged;
  }

  String _monthLabelFor(RunSummarySnapshot summary) {
    final dateLabel = summary.dateLabel.trim();
    if (dateLabel.toLowerCase() == 'today') {
      return _formatMonth(_now());
    }

    final parsedDate = DateTime.tryParse(dateLabel);
    if (parsedDate != null) {
      return _formatMonth(parsedDate);
    }

    final dayMonthYear = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$',
    ).firstMatch(dateLabel);
    if (dayMonthYear != null) {
      final month = _monthNumber(dayMonthYear.group(2)!);
      final year = int.tryParse(dayMonthYear.group(3)!);
      if (month != null && year != null) {
        return _formatMonth(DateTime(year, month));
      }
    }

    final monthYear = RegExp(r'^([A-Za-z]+)\s+(\d{4})$').firstMatch(dateLabel);
    if (monthYear != null) {
      final month = _monthNumber(monthYear.group(1)!);
      final year = int.tryParse(monthYear.group(2)!);
      if (month != null && year != null) {
        return _formatMonth(DateTime(year, month));
      }
    }

    return _formatMonth(_now());
  }

  static String _formatMonth(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  static int? _monthNumber(String name) {
    final normalized = name.toLowerCase();
    for (var index = 0; index < _monthNames.length; index++) {
      if (_monthNames[index].toLowerCase().startsWith(normalized) ||
          normalized.startsWith(_monthNames[index].toLowerCase())) {
        return index + 1;
      }
    }
    return null;
  }
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class CurrentSessionActivityHistoryScope
    extends InheritedNotifier<CurrentSessionActivityHistoryStore> {
  const CurrentSessionActivityHistoryScope({
    required CurrentSessionActivityHistoryStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static CurrentSessionActivityHistoryStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          CurrentSessionActivityHistoryScope
        >()
        ?.notifier;
  }

  static CurrentSessionActivityHistoryStore of(BuildContext context) {
    final store = maybeOf(context);
    assert(store != null, 'No CurrentSessionActivityHistoryScope found.');
    return store!;
  }
}
