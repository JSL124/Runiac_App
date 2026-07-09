import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/leaderboard/data/firestore_leaderboard_repository.dart';
import 'package:runiac_app/features/leaderboard/data/static_leaderboard_repository.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  test(
    'loadLeaderboard reads backend-owned current view snapshot and rank docs',
    () async {
      final authRepository = FakeRuniacAuthRepository()
        ..emitSignedIn(uid: 'runner-1');
      final reader = _FakeLeaderboardDocumentReader(
        currentView: const {
          'activeSnapshotId': 'monthly_sg_bronze_2026-07',
          'activeRankProjectionId': 'runner-1_monthly_sg_bronze_2026-07',
        },
        snapshots: const {
          'monthly_sg_bronze_2026-07': {
            'regionLabel': 'Jurong East',
            'divisionLabel': 'Bronze',
            'periodLabel': 'July 2026',
            'refreshesAt': '2026-07-31T16:00:00.000Z',
            'entries': [
              {
                'userId': 'runner-2',
                'displayName': 'Ari S.',
                'rankLabel': '#1',
                'scoreLabel': '1,480 XP',
                'levelLabel': 'Level 19',
              },
              {
                'userId': 'runner-1',
                'displayName': 'Jinseo (You)',
                'rankLabel': '#2',
                'scoreLabel': '1,320 XP',
                'levelLabel': 'Level 18',
              },
            ],
          },
        },
        ranks: const {
          'runner-1_monthly_sg_bronze_2026-07': {'rankLabel': '#2'},
        },
      );
      final repository = FirestoreLeaderboardRepository(
        authRepository: authRepository,
        reader: reader,
      );

      final leaderboard = await repository.loadLeaderboard();

      expect(leaderboard.regionLabel, 'Jurong East');
      expect(leaderboard.currentRunnerRankLabel, '#2');
      expect(leaderboard.periodLabel, 'July 2026');
      expect(leaderboard.periodEndsAt, DateTime.utc(2026, 7, 31, 16));
      expect(leaderboard.entries.map((entry) => entry.displayName), [
        'Ari S.',
        'Jinseo (You)',
      ]);
      expect(leaderboard.entries.last.scoreLabel, '1,320 XP');
      expect(reader.writes, isEmpty);
    },
  );

  test(
    'loadLeaderboard falls back when no current view is available',
    () async {
      final authRepository = FakeRuniacAuthRepository()
        ..emitSignedIn(uid: 'runner-1');
      final repository = FirestoreLeaderboardRepository(
        authRepository: authRepository,
        reader: const _FakeLeaderboardDocumentReader(currentView: null),
      );
      final fallback = await const StaticLeaderboardRepository()
          .loadLeaderboard();

      final leaderboard = await repository.loadLeaderboard();

      expect(leaderboard.regionLabel, fallback.regionLabel);
      expect(leaderboard.entries.map((entry) => entry.displayName), [
        for (final entry in fallback.entries) entry.displayName,
      ]);
    },
  );

  test('loadLeaderboard uses fallback when no user is signed in', () async {
    final repository = FirestoreLeaderboardRepository(
      authRepository: FakeRuniacAuthRepository(),
      reader: const _FakeLeaderboardDocumentReader(
        currentView: {'snapshotId': 'ignored', 'rankId': 'ignored'},
      ),
    );
    final fallback = await const StaticLeaderboardRepository()
        .loadLeaderboard();

    final leaderboard = await repository.loadLeaderboard();

    expect(leaderboard.currentRunnerRankLabel, fallback.currentRunnerRankLabel);
  });
}

class _FakeLeaderboardDocumentReader implements LeaderboardDocumentReader {
  const _FakeLeaderboardDocumentReader({
    required this.currentView,
    this.snapshots = const <String, Map<String, Object?>>{},
    this.ranks = const <String, Map<String, Object?>>{},
  });

  final Map<String, Object?>? currentView;
  final Map<String, Map<String, Object?>> snapshots;
  final Map<String, Map<String, Object?>> ranks;
  List<String> get writes => const <String>[];

  @override
  Future<Map<String, Object?>?> readCurrentView({required String uid}) async {
    return currentView;
  }

  @override
  Future<Map<String, Object?>?> readRank({required String rankId}) async {
    return ranks[rankId];
  }

  @override
  Future<Map<String, Object?>?> readSnapshot({
    required String snapshotId,
  }) async {
    return snapshots[snapshotId];
  }
}
