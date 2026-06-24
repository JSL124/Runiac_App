import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../run/domain/models/complete_run_result.dart';
import '../../run/domain/models/run_activity_display_model.dart';
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
    return <RunActivityDisplayModel>[
      for (final activity in _activities) activity.display,
      ...fallback,
    ].take(limit).toList(growable: false);
  }

  List<ActivityHistoryMonth> activityHistoryWithFallback(
    List<ActivityHistoryMonth> fallback,
  ) {
    if (_activities.isEmpty) {
      return fallback;
    }

    return <ActivityHistoryMonth>[
      ActivityHistoryMonth(
        label: 'Current Session',
        activities: [for (final activity in _activities) activity.display],
      ),
      ...fallback,
    ];
  }
}

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
