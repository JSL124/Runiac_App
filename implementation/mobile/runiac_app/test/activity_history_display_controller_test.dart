import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/you/domain/models/activity_history_read_model.dart';
import 'package:runiac_app/features/you/domain/repositories/activity_history_repository.dart';
import 'package:runiac_app/features/you/data/static_activity_history_repository.dart';
import 'package:runiac_app/features/you/presentation/current_session_activity_history.dart';
import 'package:runiac_app/features/you/presentation/activity_history_display_controller.dart';
import 'package:runiac_app/features/you/presentation/data/activity_history_demo_snapshots.dart';
import 'package:runiac_app/features/you/presentation/data/you_overview_demo_snapshots.dart';

void main() {
  group('ActivityHistoryDisplayController', () {
    test(
      'does not replace authenticated empty history with demo rows',
      () async {
        final controller = ActivityHistoryDisplayController(
          repository: _ImmediateActivityHistoryRepository(_emptyHistory()),
        );
        addTearDown(controller.dispose);
        final store = CurrentSessionActivityHistoryStore();
        addTearDown(store.dispose);

        await controller.load();

        expect(controller.recentRuns(store), isEmpty);
        expect(controller.months(store), isEmpty);
      },
    );

    test('keeps demo rows for the static repository path', () async {
      final controller = ActivityHistoryDisplayController(
        repository: const StaticActivityHistoryRepository(),
      );
      addTearDown(controller.dispose);
      final store = CurrentSessionActivityHistoryStore();
      addTearDown(store.dispose);

      await controller.load();

      expect(
        controller.recentRuns(store).map((run) => run.title),
        contains(youProgressSnapshot.runs.first.title),
      );
      expect(
        controller.months(store).map((month) => month.label),
        contains(activityHistoryDisplayData.first.label),
      );
    });

    test('ignores repository completion after dispose', () async {
      final repository = _DelayedActivityHistoryRepository();
      final controller = ActivityHistoryDisplayController(
        repository: repository,
      );
      addTearDown(() {
        if (!repository.completer.isCompleted) {
          repository.completer.complete(_emptyHistory());
        }
      });

      final load = controller.load();
      controller.dispose();
      repository.completer.complete(_emptyHistory());

      await expectLater(load, completes);
    });
  });
}

class _ImmediateActivityHistoryRepository implements ActivityHistoryRepository {
  const _ImmediateActivityHistoryRepository(this.history);

  final ActivityHistoryReadModel history;

  @override
  Future<ActivityHistoryReadModel> loadActivityHistory() async {
    return history;
  }
}

class _DelayedActivityHistoryRepository implements ActivityHistoryRepository {
  final completer = Completer<ActivityHistoryReadModel>();

  @override
  Future<ActivityHistoryReadModel> loadActivityHistory() {
    return completer.future;
  }
}

ActivityHistoryReadModel _emptyHistory() {
  return ActivityHistoryReadModel(
    recentRuns: const <ActivityHistoryItemReadModel>[],
    months: const <ActivityHistoryMonthReadModel>[],
  );
}
