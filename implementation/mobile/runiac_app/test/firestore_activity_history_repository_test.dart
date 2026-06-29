import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/you/data/firestore_activity_history_repository.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  group('FirestoreActivityHistoryRepository', () {
    test('maps owner run summaries into grouped history', () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final reader = _FakeActivityHistorySummaryDocumentReader(
        documents: <ActivityHistorySummaryDocument>[
          _runSummaryDocument(
            id: 'summary-june-2',
            ownerUid: 'test-auth-user-1',
            clientRunSessionId: 'client-session-june-2',
            endedAt: DateTime(2026, 6, 14, 7, 25),
            distanceMeters: 3200,
            durationSeconds: 1500,
            averagePaceSecondsPerKm: 469,
            title: 'Authenticated Recovery Run',
            routeLabel: 'Repository Result Route',
          ),
          _runSummaryDocument(
            id: 'summary-june-1',
            ownerUid: 'test-auth-user-1',
            endedAt: DateTime(2026, 6, 12, 6, 40),
            distanceMeters: 2400,
            durationSeconds: 1260,
            averagePaceSecondsPerKm: 525,
            routeLabel: null,
          ),
          _runSummaryDocument(
            id: 'summary-may-1',
            ownerUid: 'test-auth-user-1',
            endedAt: DateTime(2026, 5, 31, 8, 5),
            distanceMeters: 5000,
            durationSeconds: 1800,
            averagePaceSecondsPerKm: 360,
            routeLabel: 'Park loop',
          ),
        ],
      );
      final repository = FirestoreActivityHistoryRepository(
        authRepository: authRepository,
        reader: reader,
      );

      final history = await repository.loadActivityHistory();

      expect(reader.readOwnerUids, <String>['test-auth-user-1']);
      expect(reader.readLimits, <int>[30]);
      expect(history.recentRuns.map((run) => run.activityId), <String>[
        'summary-june-2',
        'summary-june-1',
        'summary-may-1',
      ]);
      expect(
        history.recentRuns.first.clientRunSessionId,
        'client-session-june-2',
      );
      expect(history.recentRuns.first.title, 'Authenticated Recovery Run');
      expect(history.recentRuns[1].title, 'Completed Run');
      expect(history.recentRuns.first.completedAtLabel, '14/6/26');
      expect(history.recentRuns.first.timeLabel, '7:25 AM');
      expect(history.recentRuns.first.distanceLabel, '3.20 km');
      expect(history.recentRuns.first.durationLabel, '25:00');
      expect(history.recentRuns.first.paceLabel, '7’49”');
      expect(
        history.recentRuns.first.routeNameLabel,
        'Repository Result Route',
      );
      expect(history.months.map((month) => month.label), <String>[
        'June 2026',
        'May 2026',
      ]);
      expect(
        history.months.first.activities.map((run) => run.activityId),
        <String>['summary-june-2', 'summary-june-1'],
      );
    });

    test('uses static fallback when no user is signed in', () async {
      final reader = _FakeActivityHistorySummaryDocumentReader();
      final repository = FirestoreActivityHistoryRepository(
        authRepository: FakeRuniacAuthRepository(),
        reader: reader,
      );

      final history = await repository.loadActivityHistory();

      expect(reader.readOwnerUids, isEmpty);
      expect(history.recentRuns, isNotEmpty);
      expect(history.months, isNotEmpty);
    });

    test('ignores wrong-owner document', () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final repository = FirestoreActivityHistoryRepository(
        authRepository: authRepository,
        reader: _FakeActivityHistorySummaryDocumentReader(
          documents: <ActivityHistorySummaryDocument>[
            _runSummaryDocument(
              id: 'owner-summary',
              ownerUid: 'test-auth-user-1',
              endedAt: DateTime(2026, 6, 14, 7, 25),
            ),
            _runSummaryDocument(
              id: 'wrong-owner-summary',
              ownerUid: 'other-user',
              endedAt: DateTime(2026, 6, 13, 7, 25),
            ),
          ],
        ),
      );

      final history = await repository.loadActivityHistory();

      expect(history.recentRuns.map((run) => run.activityId), <String>[
        'owner-summary',
      ]);
    });

    test(
      'limits recentRuns to three while months keeps grouped result',
      () async {
        final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
        final repository = FirestoreActivityHistoryRepository(
          authRepository: authRepository,
          reader: _FakeActivityHistorySummaryDocumentReader(
            documents: <ActivityHistorySummaryDocument>[
              _runSummaryDocument(
                id: 'summary-4',
                ownerUid: 'test-auth-user-1',
                endedAt: DateTime(2026, 6, 14, 7, 25),
              ),
              _runSummaryDocument(
                id: 'summary-3',
                ownerUid: 'test-auth-user-1',
                endedAt: DateTime(2026, 6, 13, 7, 25),
              ),
              _runSummaryDocument(
                id: 'summary-2',
                ownerUid: 'test-auth-user-1',
                endedAt: DateTime(2026, 6, 12, 7, 25),
              ),
              _runSummaryDocument(
                id: 'summary-1',
                ownerUid: 'test-auth-user-1',
                endedAt: DateTime(2026, 6, 11, 7, 25),
              ),
            ],
          ),
        );

        final history = await repository.loadActivityHistory();

        expect(history.recentRuns.map((run) => run.activityId), <String>[
          'summary-4',
          'summary-3',
          'summary-2',
        ]);
        expect(history.months, hasLength(1));
        expect(
          history.months.single.activities.map((run) => run.activityId),
          <String>['summary-4', 'summary-3', 'summary-2', 'summary-1'],
        );
      },
    );

    test('skips malformed docs', () async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      final repository = FirestoreActivityHistoryRepository(
        authRepository: authRepository,
        reader: _FakeActivityHistorySummaryDocumentReader(
          documents: <ActivityHistorySummaryDocument>[
            const ActivityHistorySummaryDocument(
              id: 'malformed-summary',
              data: <String, Object?>{
                'ownerUid': 'test-auth-user-1',
                'endedAt': 'not-a-date',
                'distanceMeters': 3200,
                'durationSeconds': 1500,
                'averagePaceSecondsPerKm': 469,
              },
            ),
            _runSummaryDocument(
              id: 'valid-summary',
              ownerUid: 'test-auth-user-1',
              endedAt: DateTime(2026, 6, 14, 7, 25),
            ),
          ],
        ),
      );

      final history = await repository.loadActivityHistory();

      expect(history.recentRuns.map((run) => run.activityId), <String>[
        'valid-summary',
      ]);
    });
  });
}

ActivityHistorySummaryDocument _runSummaryDocument({
  required String id,
  required String ownerUid,
  required DateTime endedAt,
  String? clientRunSessionId,
  int distanceMeters = 3200,
  int durationSeconds = 1500,
  int averagePaceSecondsPerKm = 469,
  String? routeLabel = 'Private route',
  String? title,
}) {
  final data = <String, Object?>{
    'ownerUid': ownerUid,
    'endedAt': endedAt,
    'distanceMeters': distanceMeters,
    'durationSeconds': durationSeconds,
    'averagePaceSecondsPerKm': averagePaceSecondsPerKm,
  };
  if (title != null) {
    data['title'] = title;
  }
  if (clientRunSessionId != null) {
    data['clientRunSessionId'] = clientRunSessionId;
  }
  if (routeLabel != null) {
    data['routeLabel'] = routeLabel;
  }

  return ActivityHistorySummaryDocument(id: id, data: data);
}

class _FakeActivityHistorySummaryDocumentReader
    implements ActivityHistorySummaryDocumentReader {
  _FakeActivityHistorySummaryDocumentReader({
    this.documents = const <ActivityHistorySummaryDocument>[],
  });

  final List<ActivityHistorySummaryDocument> documents;
  final List<String> readOwnerUids = <String>[];
  final List<int> readLimits = <int>[];

  @override
  Future<List<ActivityHistorySummaryDocument>> loadRunSummaries({
    required String ownerUid,
    required int limit,
  }) async {
    readOwnerUids.add(ownerUid);
    readLimits.add(limit);
    return documents;
  }
}
