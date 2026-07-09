import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/leaderboard/data/firestore_leaderboard_repository.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';

import 'support/fake_runiac_auth_repository.dart';

void main() {
  test('loads bounded live top and owner-nearby monthly projections', () async {
    final authRepository = FakeRuniacAuthRepository()
      ..emitSignedIn(uid: 'runner-1');
    final reader = _FakeLeaderboardDocumentReader(
      period: const {
        'periodKey': '2026-07',
        'periodLabel': 'July 2026',
        'refreshesAt': '2026-07-31T16:00:00.000Z',
      },
      currentView: const {
        'homeRegionId': 'jurong-east',
        'divisionKey': 'tier_02',
        'status': 'ranked',
        'activeSnapshotId': 'monthly_jurong-east_tier_02_2026-07',
        'activeRankProjectionId': 'runner-1_monthly_2026-07',
      },
      profile: const {
        'locationLabel': 'Jurong East, Singapore',
        'divisionKey': 'tier_02',
      },
      snapshots: const {
        'monthly_jurong-east_tier_02_2026-07': {
          'regionLabel': 'Jurong East',
          'divisionLabel': 'Bronze League',
          'topEntries': [
            {
              'publicAlias': 'Ari S.',
              'rankLabel': '#1',
              'scoreLabel': '1,480 XP',
              'levelLabel': 'Level 19',
              'divisionLabel': 'Bronze League',
              'regionLabel': 'Jurong East',
            },
          ],
        },
      },
      ranks: const {
        'runner-1_monthly_2026-07': {
          'rankLabel': '#12',
          'currentEntry': {'publicAlias': 'Jinseo', 'rankLabel': '#12'},
          'nearbyEntries': [
            {
              'publicAlias': 'Jinseo',
              'rankLabel': '#12',
              'scoreLabel': '1,320 XP',
              'levelLabel': 'Level 18',
              'divisionLabel': 'Bronze League',
              'regionLabel': 'Jurong East',
            },
          ],
        },
      },
    );
    final repository = FirestoreLeaderboardRepository(
      authRepository: authRepository,
      reader: reader,
    );

    final leaderboard = await repository.loadLeaderboard();

    expect(leaderboard.status, LeaderboardReadStatus.data);
    expect(leaderboard.regionId, 'jurong-east');
    expect(leaderboard.divisionLabel, 'Bronze League');
    expect(leaderboard.currentRunnerRankLabel, '#12');
    expect(leaderboard.entries.single.displayName, 'Ari S.');
    expect(leaderboard.nearbyEntries.single.displayName, 'Jinseo');
    expect(leaderboard.nearbyEntries.single.isCurrentUser, isTrue);
    expect(leaderboard.periodLabel, 'July 2026');
    expect(leaderboard.periodEndsAt, DateTime.utc(2026, 7, 31, 16));
  });

  test('uses selected profile planning area for an unranked owner', () async {
    final authRepository = FakeRuniacAuthRepository()
      ..emitSignedIn(uid: 'runner-1');
    final reader = _FakeLeaderboardDocumentReader(
      period: const {'periodKey': '2026-07', 'periodLabel': 'July 2026'},
      currentView: null,
      profile: const {
        'locationLabel': 'Tampines, Singapore',
        'divisionKey': 'tier_01',
      },
      snapshots: const {
        'monthly_tampines_tier_01_2026-07': {
          'divisionLabel': 'Iron League',
          'topEntries': [],
        },
      },
    );
    final repository = FirestoreLeaderboardRepository(
      authRepository: authRepository,
      reader: reader,
    );

    final leaderboard = await repository.loadLeaderboard();

    expect(leaderboard.status, LeaderboardReadStatus.unranked);
    expect(leaderboard.homeRegionId, 'tampines');
    expect(leaderboard.regionLabel, 'Tampines');
    expect(leaderboard.entries, isEmpty);
  });

  test('returns region-required without demo fallback', () async {
    final authRepository = FakeRuniacAuthRepository()
      ..emitSignedIn(uid: 'runner-1');
    final repository = FirestoreLeaderboardRepository(
      authRepository: authRepository,
      reader: const _FakeLeaderboardDocumentReader(
        period: {'periodKey': '2026-07'},
        currentView: null,
        profile: {'locationLabel': 'Tuas, Singapore'},
      ),
    );

    final leaderboard = await repository.loadLeaderboard();

    expect(leaderboard.status, LeaderboardReadStatus.regionRequired);
    expect(leaderboard.entries, isEmpty);
    expect(leaderboard.regionLabel, isEmpty);
  });

  test('loads a tapped supported region from the live snapshot path', () async {
    final authRepository = FakeRuniacAuthRepository()
      ..emitSignedIn(uid: 'runner-1');
    final reader = _FakeLeaderboardDocumentReader(
      period: const {'periodKey': '2026-07'},
      currentView: const {
        'homeRegionId': 'jurong-east',
        'divisionKey': 'tier_01',
        'status': 'ranked',
      },
      profile: const {'locationLabel': 'Jurong East, Singapore'},
      snapshots: const {
        'monthly_tampines_tier_01_2026-07': {
          'divisionLabel': 'Iron League',
          'topEntries': [
            {
              'publicAlias': 'Tampines Runner',
              'rankLabel': '#1',
              'scoreLabel': '900 XP',
              'levelLabel': 'Level 3',
              'divisionLabel': 'Iron League',
              'regionLabel': 'Tampines',
            },
          ],
        },
      },
    );
    final repository = FirestoreLeaderboardRepository(
      authRepository: authRepository,
      reader: reader,
    );

    final leaderboard = await repository.loadRegion(regionId: 'tampines');

    expect(leaderboard.regionId, 'tampines');
    expect(leaderboard.isHomeRegion, isFalse);
    expect(leaderboard.entries.single.displayName, 'Tampines Runner');
    expect(reader.snapshotReads, contains('monthly_tampines_tier_01_2026-07'));
  });

  test('requires authentication instead of returning static people', () async {
    final repository = FirestoreLeaderboardRepository(
      authRepository: FakeRuniacAuthRepository(),
      reader: const _FakeLeaderboardDocumentReader(
        period: {'periodKey': '2026-07'},
        currentView: null,
      ),
    );

    await expectLater(repository.loadLeaderboard(), throwsStateError);
  });
}

class _FakeLeaderboardDocumentReader implements LeaderboardDocumentReader {
  const _FakeLeaderboardDocumentReader({
    required this.period,
    required this.currentView,
    this.profile,
    this.snapshots = const <String, Map<String, Object?>>{},
    this.ranks = const <String, Map<String, Object?>>{},
  });

  final Map<String, Object?>? period;
  final Map<String, Object?>? currentView;
  final Map<String, Object?>? profile;
  final Map<String, Map<String, Object?>> snapshots;
  final Map<String, Map<String, Object?>> ranks;
  static final List<String> _snapshotReads = [];
  List<String> get snapshotReads => List.unmodifiable(_snapshotReads);

  @override
  Future<Map<String, Object?>?> readCurrentPeriod() async => period;

  @override
  Future<Map<String, Object?>?> readCurrentView({required String uid}) async {
    return currentView;
  }

  @override
  Future<Map<String, Object?>?> readProfile({required String uid}) async {
    return profile;
  }

  @override
  Future<Map<String, Object?>?> readRank({required String rankId}) async {
    return ranks[rankId];
  }

  @override
  Future<Map<String, Object?>?> readSnapshot({
    required String snapshotId,
  }) async {
    _snapshotReads.add(snapshotId);
    return snapshots[snapshotId];
  }
}
