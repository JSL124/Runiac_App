import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import '../domain/models/progression_display_model.dart';
import '../domain/models/run_activity_read_model.dart';
import '../domain/models/run_completion_error.dart';
import '../domain/models/run_completion_request_adapter.dart';
import '../domain/models/run_summary_read_model.dart';
import '../domain/models/run_summary_snapshot.dart';
import '../domain/models/xp_update_display_model.dart';
import '../domain/repositories/run_repository.dart';
import '../domain/services/completed_run_title_formatter.dart';
import '../domain/services/run_calories_estimator.dart';
import 'static_run_repository.dart';

abstract interface class CompleteRunCallable {
  Future<Map<String, Object?>> call(Map<String, Object?> request);
}

class CompleteRunCallableException implements Exception {
  const CompleteRunCallableException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class FirebaseRunRepository implements RunRepository {
  const FirebaseRunRepository({
    required this.callable,
    this.staticFallback = const StaticRunRepository(),
  });

  final CompleteRunCallable callable;
  final RunRepository staticFallback;

  @override
  Future<CompleteRunResult> completeRun(
    LocalRunCompletionPayload payload,
  ) async {
    final request = RunCompletionRequestAdapter.toBackendRequest(payload);

    final response = await callable.call(request).onError((error, stackTrace) {
      if (error is CompleteRunCallableException) {
        throw RunCompletionException(
          code: error.code,
          message: error.message,
          isRetryable: _isRetryableCallableCode(error.code),
        );
      }
      throw RunCompletionException(
        code: 'unknown',
        message: 'Run completion failed before the emulator responded.',
        isRetryable: true,
      );
    });

    return _CompleteRunResultMapper.fromCallableResponse(response);
  }

  @override
  Future<CompleteRunResult> loadLatestCompletionResult() {
    return staticFallback.loadLatestCompletionResult();
  }

  @override
  Future<RunActivityReadModel> loadLatestRunActivity() {
    return staticFallback.loadLatestRunActivity();
  }

  @override
  Future<RunSummaryReadModel> loadLatestRunSummary() {
    return staticFallback.loadLatestRunSummary();
  }

  bool _isRetryableCallableCode(String code) {
    return code == 'unavailable' ||
        code == 'deadline-exceeded' ||
        code == 'internal';
  }
}

class _CompleteRunResultMapper {
  const _CompleteRunResultMapper._();

  static CompleteRunResult fromCallableResponse(Map<String, Object?> response) {
    final summary = _readMap(response, 'runSummary');
    final progression = _readMap(response, 'progressionDisplay');
    final paceSeconds = _readInt(summary, 'averagePaceSecondsPerKm');
    final distanceMeters = _readInt(summary, 'distanceMeters');
    final durationSeconds = _readInt(summary, 'durationSeconds');
    final endedAt = _readDate(summary, 'endedAt');
    final calories = const RunCaloriesEstimator().estimate(
      bodyWeightKg: demoBodyWeightKgForCalories,
      movingSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      averagePaceSecondsPerKm: paceSeconds,
    );

    return CompleteRunResult(
      activityId: _readString(response, 'activityId'),
      summaryId: _readString(response, 'summaryId'),
      progressionEventId: _readString(response, 'progressionEventId'),
      validationStatus: _readString(response, 'validationStatus'),
      summary: RunSummarySnapshot(
        title: const CompletedRunTitleFormatter().format(completedAt: endedAt),
        dateLabel: _formatDate(endedAt),
        timeLabel: _formatTime(endedAt),
        distanceKm: _formatDistanceKm(distanceMeters),
        avgPace: _formatPace(paceSeconds),
        duration: _formatDuration(durationSeconds),
        avgHeartRate: '--',
        calories: _formatCalories(calories),
        routeName:
            _readOptionalString(summary, 'routeLabel') ?? 'Private route',
      ),
      progressionDisplay: ProgressionDisplayModel(
        xpDelta: _readInt(progression, 'xpDelta'),
        countsTowardLeaderboard: _readBool(
          progression,
          'countsTowardLeaderboard',
        ),
        status: _readString(progression, 'status'),
        reason: _readString(progression, 'reason'),
      ),
      xpUpdate: const XpUpdateDisplayModel(
        runnerName: 'Runiac Runner',
        earnedXpLabel: '+0 XP',
        totalXpLabel: 'Deferred by backend',
        levelLabel: 'Pending',
        nextLevelLabel: 'Pending',
        progressTargetLabel: 'Pending',
        xpRemainingLabel: 'Formula pending',
        previousProgressFraction: 0,
        currentProgressFraction: 0,
        streakChangeLabel: 'Deferred',
        streakNote: 'Backend validation accepted the run.',
        didLevelUp: false,
      ),
      message: _readString(response, 'message'),
    );
  }

  static Map<String, Object?> _readMap(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static String _readString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static String? _readOptionalString(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value == null) {
      return null;
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static int _readInt(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num && value.isFinite) {
      return value.round();
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static bool _readBool(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is bool) {
      return value;
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static DateTime _readDate(Map<String, Object?> source, String key) {
    final value = DateTime.tryParse(_readString(source, key));
    if (value != null) {
      return value;
    }
    throw const RunCompletionException(
      code: 'invalid-response',
      message: 'The emulator returned an invalid run completion response.',
      isRetryable: true,
    );
  }

  static String _formatDistanceKm(int distanceMeters) {
    return (distanceMeters / 1000).toStringAsFixed(2);
  }

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatPace(int paceSecondsPerKm) {
    if (paceSecondsPerKm <= 0) {
      return '--';
    }

    final minutes = paceSecondsPerKm ~/ 60;
    final seconds = paceSecondsPerKm % 60;
    return '$minutes’${seconds.toString().padLeft(2, '0')}”';
  }

  static String _formatCalories(int? calories) {
    return calories == null ? '--' : calories.toString();
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().substring(2);
    return '${local.day}/${local.month}/$year';
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
