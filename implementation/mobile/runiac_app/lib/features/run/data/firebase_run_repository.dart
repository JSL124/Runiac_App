import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import '../domain/models/pace_graph_snapshot.dart';
import '../domain/models/progression_display_model.dart';
import '../domain/models/run_activity_read_model.dart';
import '../domain/models/run_completion_error.dart';
import '../domain/models/run_completion_request_adapter.dart';
import '../domain/models/run_summary_read_model.dart';
import '../domain/models/run_summary_snapshot.dart';
import '../domain/models/xp_update_display_model.dart';
import '../domain/repositories/run_repository.dart';
import '../domain/services/run_summary_scalar_mapper.dart';
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

    return _CompleteRunResultMapper.fromCallableResponse(
      response,
    ).copyWith(clientRunSessionId: payload.clientRunSessionId);
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
    final scalar = const RunSummaryScalarMapper().map(
      completedAt: endedAt,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      averagePaceSecondsPerKm: paceSeconds,
      routeLabel: _readOptionalString(summary, 'routeLabel'),
    );

    return CompleteRunResult(
      activityId: _readString(response, 'activityId'),
      summaryId: _readString(response, 'summaryId'),
      progressionEventId: _readString(response, 'progressionEventId'),
      validationStatus: _readString(response, 'validationStatus'),
      summary: RunSummarySnapshot(
        title: scalar.title,
        dateLabel: scalar.dateLabel,
        timeLabel: scalar.timeLabel,
        distanceKm: scalar.distanceKm,
        avgPace: scalar.avgPace,
        duration: scalar.duration,
        avgHeartRate: '--',
        calories: scalar.calories,
        routeName: scalar.routeName,
        hasSufficientData: scalar.hasSufficientData,
        paceGraph: const PaceGraphSnapshot.unavailable(
          unavailableReason: 'backend_graph_data_unavailable',
        ),
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
      xpUpdate: _buildXpUpdate(progression),
      message: _readString(response, 'message'),
    );
  }

  /// Builds the XP & Streak display model purely from backend-owned progression
  /// values. The client never calculates XP, level, streak, or progress
  /// fractions; fractions are backend percents divided by 100.
  static XpUpdateDisplayModel _buildXpUpdate(Map<String, Object?> progression) {
    const runnerName = 'Runiac Runner';
    final status = _readString(progression, 'status');
    final reason = _readString(progression, 'reason');
    final xpDelta = _readInt(progression, 'xpDelta');
    final hasProgressionNumbers =
        progression.containsKey('totalXp') &&
        progression.containsKey('previousTotalXp');

    if (status == 'deferred' || !hasProgressionNumbers) {
      return const XpUpdateDisplayModel(
        runnerName: runnerName,
        earnedXpLabel: '+0 XP',
        totalXpLabel: 'Saved',
        levelLabel: '--',
        nextLevelLabel: '--',
        progressTargetLabel: 'Progression pending',
        xpRemainingLabel: 'Finalizing',
        previousProgressFraction: 0,
        currentProgressFraction: 0,
        streakChangeLabel: 'Streak saved',
        streakNote: 'Saved',
        didLevelUp: false,
        xpAwardState: XpAwardState.deferred,
        heroMessage: 'This run is saved. XP is being finalized.',
      );
    }

    final totalXp = _readInt(progression, 'totalXp');
    final previousTotalXp = _readIntOr(progression, 'previousTotalXp', totalXp);
    final level = _readIntOr(progression, 'level', 0);
    final previousLevel = _readIntOr(progression, 'previousLevel', level);
    final previousPercent = _readIntOr(
      progression,
      'previousLevelProgressPercent',
      0,
    );
    final currentPercent = _readIntOr(progression, 'levelProgressPercent', 0);
    final streak = _readIntOr(progression, 'streak', 0);
    final previousStreak = _readIntOr(progression, 'previousStreak', streak);
    final xpToNextLevel = _readNullableInt(progression, 'xpToNextLevel');
    final isMaxLevel = xpToNextLevel == null;
    final didLevelUp = level > previousLevel;
    final awarded = status == 'awarded' && xpDelta > 0;
    final nextLevel = level + 1;

    return XpUpdateDisplayModel(
      runnerName: runnerName,
      earnedXpLabel: '+${_formatThousands(xpDelta)} XP',
      totalXpLabel: '${_formatThousands(totalXp)} XP',
      levelLabel: '$level',
      nextLevelLabel: isMaxLevel ? '$level' : '$nextLevel',
      progressTargetLabel: isMaxLevel
          ? 'Max level reached'
          : 'Progress to Level $nextLevel',
      xpRemainingLabel: isMaxLevel
          ? 'Max level reached'
          : '${_formatThousands(xpToNextLevel)} XP to Level $nextLevel',
      previousProgressFraction: previousPercent / 100.0,
      currentProgressFraction: currentPercent / 100.0,
      streakChangeLabel: _streakChangeLabel(previousStreak, streak),
      streakNote: streak > previousStreak ? 'Keep it going' : 'Nice work',
      didLevelUp: didLevelUp,
      xpAwardState: awarded ? XpAwardState.awarded : XpAwardState.notAwarded,
      heroMessage: awarded
          ? (didLevelUp
                ? 'You reached Level $level. Keep it up.'
                : 'Earned from this run')
          : _notAwardedMessage(reason),
      earnedXp: xpDelta,
      totalXp: totalXp,
      previousTotalXp: previousTotalXp,
      level: level,
      previousLevel: previousLevel,
      streakCount: streak,
      previousStreakCount: previousStreak,
    );
  }

  static String _streakChangeLabel(int previousStreak, int streak) {
    if (streak <= 0) {
      return 'Streak saved';
    }
    final unit = streak == 1 ? 'day' : 'days';
    if (streak > previousStreak) {
      return '$previousStreak → $streak $unit';
    }
    return '$streak $unit';
  }

  static String _notAwardedMessage(String reason) {
    switch (reason) {
      case 'low_data_no_xp':
        return 'Run a little longer to earn XP';
      case 'daily_cap_reached':
        return 'Daily XP cap reached — great effort today';
      case 'premium_no_progression':
        return 'Premium runs stay off the XP board — enjoy the run';
      default:
        return 'This run didn\'t earn XP';
    }
  }

  static String _formatThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index += 1) {
      if (index != 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }
    return '${value < 0 ? '-' : ''}$buffer';
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

  static int _readIntOr(
    Map<String, Object?> source,
    String key,
    int fallback,
  ) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num && value.isFinite) {
      return value.round();
    }
    return fallback;
  }

  /// Reads a backend field that is a number, an explicit `null` (for example a
  /// max-level `xpToNextLevel`), or absent. Returns `null` for both the
  /// explicit null and the absent case so callers treat max level as "no next
  /// level" without inventing a value.
  static int? _readNullableInt(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num && value.isFinite) {
      return value.round();
    }
    return null;
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
}
