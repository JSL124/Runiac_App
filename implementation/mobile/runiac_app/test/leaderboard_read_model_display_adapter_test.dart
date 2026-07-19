import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';
import 'package:runiac_app/features/leaderboard/presentation/leaderboard_read_model_display_adapter.dart';
import 'package:runiac_app/features/leaderboard/presentation/models/leaderboard_display_models.dart';

void main() {
  final now = DateTime.utc(2026, 7, 10);

  LeaderboardRowReadModel row({
    String userId = 'runner',
    String displayName = 'Runner',
    String rankLabel = '#1',
    String scoreLabel = '100 XP',
    bool isCurrentUser = false,
  }) {
    return LeaderboardRowReadModel(
      userId: userId,
      displayName: displayName,
      rankLabel: rankLabel,
      scoreLabel: scoreLabel,
      isCurrentUser: isCurrentUser,
    );
  }

  LeaderboardReadModel model({
    LeaderboardReadStatus status = LeaderboardReadStatus.data,
    String currentRunnerRankLabel = '',
    List<LeaderboardRowReadModel> entries = const <LeaderboardRowReadModel>[],
    List<LeaderboardRowReadModel> nearbyEntries =
        const <LeaderboardRowReadModel>[],
  }) {
    return LeaderboardReadModel(
      status: status,
      regionLabel: 'Jurong East',
      currentRunnerRankLabel: currentRunnerRankLabel,
      entries: entries,
      nearbyEntries: nearbyEntries,
    );
  }

  group('status passthrough', () {
    for (final status in LeaderboardReadStatus.values) {
      test('passes through $status verbatim', () {
        final snapshot = leaderboardDisplaySnapshotFromReadModel(
          model(status: status),
          now,
        );

        expect(snapshot.status, status);
      });
    }
  });

  group('hasCurrentUserRank', () {
    test(
      'is true when a current-user nearby row and rank label are present',
      () {
        final snapshot = leaderboardDisplaySnapshotFromReadModel(
          model(
            currentRunnerRankLabel: '#12',
            nearbyEntries: [
              row(userId: 'me', displayName: 'Me', isCurrentUser: true),
            ],
          ),
          now,
        );

        expect(snapshot.hasCurrentUserRank, isTrue);
      },
    );

    test('is false when the current runner rank label is empty', () {
      final snapshot = leaderboardDisplaySnapshotFromReadModel(
        model(
          currentRunnerRankLabel: '',
          nearbyEntries: [
            row(userId: 'me', displayName: 'Me', isCurrentUser: true),
          ],
        ),
        now,
      );

      expect(snapshot.hasCurrentUserRank, isFalse);
    });

    test('is false when no nearby row belongs to the current user', () {
      final snapshot = leaderboardDisplaySnapshotFromReadModel(
        model(
          currentRunnerRankLabel: '#12',
          nearbyEntries: [row(userId: 'other', displayName: 'Other')],
        ),
        now,
      );

      expect(snapshot.hasCurrentUserRank, isFalse);
    });
  });

  group('ordinal medal tones', () {
    test('map by list position regardless of rank label format', () {
      final snapshot = leaderboardDisplaySnapshotFromReadModel(
        model(
          entries: [
            row(userId: 'a', rankLabel: '12th'),
            row(userId: 'b', rankLabel: '5th'),
            row(userId: 'c', rankLabel: '99th'),
            row(userId: 'd', rankLabel: '#1'),
          ],
        ),
        now,
      );

      expect(snapshot.topRanks[0].medalTone, RegionPreviewMedalTone.gold);
      expect(snapshot.topRanks[0].trophy, isTrue);
      expect(snapshot.topRanks[1].medalTone, RegionPreviewMedalTone.silver);
      expect(snapshot.topRanks[1].trophy, isFalse);
      expect(snapshot.topRanks[2].medalTone, RegionPreviewMedalTone.bronze);
      expect(snapshot.topRanks[2].trophy, isFalse);
      expect(snapshot.topRanks[3].medalTone, isNull);
      expect(snapshot.topRanks[3].trophy, isFalse);
    });
  });

  group('nearby rows', () {
    test('never receive a medal tone or trophy', () {
      final snapshot = leaderboardDisplaySnapshotFromReadModel(
        model(
          nearbyEntries: [
            row(userId: 'a', rankLabel: '#1'),
            row(userId: 'b', rankLabel: '#2'),
            row(userId: 'c', rankLabel: '#3'),
          ],
        ),
        now,
      );

      for (final nearbyRow in snapshot.nearbyRanks) {
        expect(nearbyRow.medalTone, isNull);
        expect(nearbyRow.trophy, isFalse);
      }
    });

    test('nearby section title reads "Ranks near you"', () {
      final snapshot = leaderboardDisplaySnapshotFromReadModel(model(), now);

      expect(snapshot.nearbyRanksTitle, 'Ranks near you');
    });
  });
}
