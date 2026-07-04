import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/runiac_auth_service.dart';
import '../../run/domain/services/run_summary_scalar_mapper.dart';
import '../domain/models/activity_history_read_model.dart';
import '../domain/repositories/activity_history_repository.dart';
import 'static_activity_history_repository.dart';

abstract interface class ActivityHistorySummaryDocumentReader {
  Future<List<ActivityHistorySummaryDocument>> loadRunSummaries({
    required String ownerUid,
    required int limit,
  });

  Future<List<ActivityHistorySummaryDocument>> loadActivities({
    required String ownerUid,
    required int limit,
  });
}

class ActivityHistorySummaryDocument {
  const ActivityHistorySummaryDocument({required this.id, required this.data});

  final String id;
  final Map<String, Object?> data;
}

class FirestoreActivityHistorySummaryDocumentReader
    implements ActivityHistorySummaryDocumentReader {
  FirestoreActivityHistorySummaryDocumentReader({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ActivityHistorySummaryDocument>> loadRunSummaries({
    required String ownerUid,
    required int limit,
  }) async {
    final snapshot = await _firestore
        .collection('runSummaries')
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('endedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (document) => ActivityHistorySummaryDocument(
            id: document.id,
            data: Map<String, Object?>.from(document.data()),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ActivityHistorySummaryDocument>> loadActivities({
    required String ownerUid,
    required int limit,
  }) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('endedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (document) => ActivityHistorySummaryDocument(
            id: document.id,
            data: Map<String, Object?>.from(document.data()),
          ),
        )
        .toList(growable: false);
  }
}

class FirestoreActivityHistoryRepository implements ActivityHistoryRepository {
  FirestoreActivityHistoryRepository({
    required this.authRepository,
    ActivityHistorySummaryDocumentReader? reader,
    ActivityHistoryRepository? fallbackRepository,
    this.mapper = const RunSummaryScalarMapper(),
    this.limit = 30,
  }) : documentReader =
           reader ?? FirestoreActivityHistorySummaryDocumentReader(),
       fallbackRepository =
           fallbackRepository ?? StaticActivityHistoryRepository();

  final RuniacAuthRepository authRepository;
  final ActivityHistorySummaryDocumentReader documentReader;
  final ActivityHistoryRepository fallbackRepository;
  final int limit;
  final RunSummaryScalarMapper mapper;

  @override
  Future<ActivityHistoryReadModel> loadActivityHistory() async {
    final currentUser = authRepository.currentUser;
    if (currentUser == null) {
      return fallbackRepository.loadActivityHistory();
    }

    final summaryDocuments = await documentReader.loadRunSummaries(
      ownerUid: currentUser.uid,
      limit: limit,
    );
    final activityDocuments = await documentReader.loadActivities(
      ownerUid: currentUser.uid,
      limit: limit,
    );
    final activities = _dedupeByIdentity(<_MappedActivity>[
      ..._mapDocuments(
        currentUser.uid,
        summaryDocuments,
        dateKeys: const ['endedAt', 'completedAt'],
      ),
      ..._mapDocuments(
        currentUser.uid,
        activityDocuments,
        dateKeys: const ['completedAt', 'endedAt'],
      ),
    ])..sort((left, right) => right.endedAt.compareTo(left.endedAt));

    return ActivityHistoryReadModel(
      recentRuns: activities
          .map((activity) => activity.item)
          .take(3)
          .toList(growable: false),
      months: _groupByMonth(activities),
    );
  }

  _MappedActivity? _mapDocument(
    String ownerUid,
    ActivityHistorySummaryDocument document, {
    required List<String> dateKeys,
  }) {
    final data = document.data;
    if (_readRequiredString(data, 'ownerUid') != ownerUid) {
      return null;
    }

    final endedAt = _readDateTimeFromAny(data, dateKeys);
    final distanceMeters = _readInt(data, 'distanceMeters');
    final durationSeconds = _readInt(data, 'durationSeconds');
    final averagePaceSecondsPerKm = _readInt(data, 'averagePaceSecondsPerKm');
    if (endedAt == null ||
        distanceMeters == null ||
        durationSeconds == null ||
        averagePaceSecondsPerKm == null) {
      return null;
    }

    final activityId = _readOptionalString(data, 'activityId') ?? document.id;
    final clientRunSessionId = _readOptionalString(data, 'clientRunSessionId');
    final scalar = mapper.map(
      completedAt: endedAt,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      averagePaceSecondsPerKm: averagePaceSecondsPerKm,
      routeLabel: _readOptionalString(data, 'routeLabel'),
    );
    return _MappedActivity(
      endedAt: endedAt,
      identityKey: clientRunSessionId != null && clientRunSessionId.isNotEmpty
          ? 'client:$clientRunSessionId'
          : 'activity:$activityId',
      item: ActivityHistoryItemReadModel(
        activityId: activityId,
        clientRunSessionId: clientRunSessionId,
        title: _readOptionalString(data, 'title') ?? 'Completed Run',
        completedAtLabel: scalar.dateLabel,
        distanceLabel: '${scalar.distanceKm} km',
        distanceMeters: distanceMeters,
        paceLabel: scalar.avgPace,
        durationLabel: scalar.duration,
        timeLabel: scalar.timeLabel,
        routeNameLabel: scalar.routeName,
      ),
    );
  }

  List<_MappedActivity> _mapDocuments(
    String ownerUid,
    List<ActivityHistorySummaryDocument> documents, {
    required List<String> dateKeys,
  }) {
    return documents
        .map((document) => _mapDocument(ownerUid, document, dateKeys: dateKeys))
        .nonNulls
        .toList(growable: false);
  }

  List<_MappedActivity> _dedupeByIdentity(List<_MappedActivity> activities) {
    final byIdentity = <String, _MappedActivity>{};
    for (final activity in activities) {
      byIdentity.putIfAbsent(activity.identityKey, () => activity);
    }
    return byIdentity.values.toList(growable: false);
  }

  DateTime? _readDateTimeFromAny(
    Map<String, Object?> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readDateTime(source, key);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  List<ActivityHistoryMonthReadModel> _groupByMonth(
    List<_MappedActivity> activities,
  ) {
    final monthBuckets = <String, List<ActivityHistoryItemReadModel>>{};
    for (final activity in activities) {
      final label = _monthLabel(activity.endedAt);
      monthBuckets
          .putIfAbsent(label, () => <ActivityHistoryItemReadModel>[])
          .add(activity.item);
    }

    return monthBuckets.entries
        .map(
          (entry) => ActivityHistoryMonthReadModel(
            label: entry.key,
            activities: entry.value,
          ),
        )
        .toList(growable: false);
  }

  String _monthLabel(DateTime value) {
    final local = value.toLocal();
    return '${_monthName(local.month)} ${local.year}';
  }

  String _monthName(int month) {
    return switch (month) {
      DateTime.january => 'January',
      DateTime.february => 'February',
      DateTime.march => 'March',
      DateTime.april => 'April',
      DateTime.may => 'May',
      DateTime.june => 'June',
      DateTime.july => 'July',
      DateTime.august => 'August',
      DateTime.september => 'September',
      DateTime.october => 'October',
      DateTime.november => 'November',
      DateTime.december => 'December',
      _ => 'Unknown',
    };
  }

  String? _readRequiredString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  String? _readOptionalString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  int? _readInt(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num && value.isFinite) {
      return value.round();
    }
    return null;
  }

  DateTime? _readDateTime(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class _MappedActivity {
  const _MappedActivity({
    required this.endedAt,
    required this.identityKey,
    required this.item,
  });

  final DateTime endedAt;
  final String identityKey;
  final ActivityHistoryItemReadModel item;
}
