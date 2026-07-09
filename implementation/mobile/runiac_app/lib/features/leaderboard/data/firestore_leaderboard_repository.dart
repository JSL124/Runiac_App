import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/runiac_auth_service.dart';
import '../domain/models/leaderboard_read_model.dart';
import '../domain/repositories/leaderboard_repository.dart';
import 'static_leaderboard_repository.dart';

abstract interface class LeaderboardDocumentReader {
  Future<Map<String, Object?>?> readCurrentView({required String uid});

  Future<Map<String, Object?>?> readSnapshot({required String snapshotId});

  Future<Map<String, Object?>?> readRank({required String rankId});
}

class FirestoreLeaderboardDocumentReader implements LeaderboardDocumentReader {
  FirestoreLeaderboardDocumentReader({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, Object?>?> readCurrentView({required String uid}) {
    return _readDocument('leaderboardCurrentViews/$uid');
  }

  @override
  Future<Map<String, Object?>?> readRank({required String rankId}) {
    return _readDocument('leaderboardUserRanks/$rankId');
  }

  @override
  Future<Map<String, Object?>?> readSnapshot({required String snapshotId}) {
    return _readDocument('leaderboardSnapshots/$snapshotId');
  }

  Future<Map<String, Object?>?> _readDocument(String path) async {
    final snapshot = await _firestore.doc(path).get();
    final data = snapshot.data();
    return data == null ? null : Map<String, Object?>.from(data);
  }
}

class FirestoreLeaderboardRepository implements LeaderboardRepository {
  FirestoreLeaderboardRepository({
    required this.authRepository,
    LeaderboardDocumentReader? reader,
    this.fallbackRepository = const StaticLeaderboardRepository(),
  }) : _reader = reader ?? FirestoreLeaderboardDocumentReader();

  final RuniacAuthRepository authRepository;
  final LeaderboardDocumentReader _reader;
  final LeaderboardRepository fallbackRepository;

  @override
  Future<LeaderboardReadModel> loadLeaderboard() async {
    final currentUser = authRepository.currentUser;
    final fallback = await fallbackRepository.loadLeaderboard();
    if (currentUser == null) {
      return fallback;
    }

    final currentView = await _reader.readCurrentView(uid: currentUser.uid);
    final snapshotId = _firstString([
      currentView?['activeSnapshotId'],
      currentView?['snapshotId'],
    ]);
    if (snapshotId.isEmpty) {
      return fallback;
    }

    final snapshot = await _reader.readSnapshot(snapshotId: snapshotId);
    if (snapshot == null) {
      return fallback;
    }

    final rankId = _firstString([
      currentView?['activeRankProjectionId'],
      currentView?['rankId'],
    ]);
    final rank = rankId.isEmpty ? null : await _reader.readRank(rankId: rankId);
    final entries = _entriesFromSnapshot(snapshot);

    return LeaderboardReadModel(
      regionLabel: _stringOrFallback(
        snapshot['regionLabel'],
        fallback: fallback.regionLabel,
      ),
      currentRunnerRankLabel: _stringOrFallback(
        rank?['rankLabel'],
        fallback: fallback.currentRunnerRankLabel,
      ),
      entries: entries.isEmpty ? fallback.entries : entries,
      periodEndsAt:
          _dateTimeOrNull(snapshot['refreshesAt']) ??
          _dateTimeOrNull(snapshot['periodEndAt']),
      periodLabel: _stringOrNull(snapshot['periodLabel']),
    );
  }

  List<LeaderboardRowReadModel> _entriesFromSnapshot(
    Map<String, Object?> snapshot,
  ) {
    final rawEntries = snapshot['entries'];
    if (rawEntries is! List<Object?>) {
      return const <LeaderboardRowReadModel>[];
    }

    final entries = <LeaderboardRowReadModel>[];
    for (final rawEntry in rawEntries) {
      if (rawEntry is! Map) {
        continue;
      }
      entries.add(
        LeaderboardRowReadModel(
          userId: _string(rawEntry['userId']),
          displayName: _string(rawEntry['displayName']),
          rankLabel: _string(rawEntry['rankLabel']),
          scoreLabel: _string(rawEntry['scoreLabel']),
          levelLabel: _string(rawEntry['levelLabel']),
          divisionLabel: _string(rawEntry['divisionLabel']),
          regionLabel: _string(rawEntry['regionLabel']),
        ),
      );
    }
    return entries;
  }

  String _string(Object? value) {
    return value is String ? value.trim() : '';
  }

  String _firstString(List<Object?> values) {
    for (final value in values) {
      final parsed = _string(value);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }

  String _stringOrFallback(Object? value, {required String fallback}) {
    final parsed = _string(value);
    return parsed.isEmpty ? fallback : parsed;
  }

  String? _stringOrNull(Object? value) {
    final parsed = _string(value);
    return parsed.isEmpty ? null : parsed;
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
