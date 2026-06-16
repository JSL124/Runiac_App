import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/firebase_run_repository.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_completion_error.dart';

void main() {
  group('FirebaseRunRepository', () {
    test('maps callable response into CompleteRunResult', () async {
      final callable = _FakeCompleteRunCallable(
        response: <String, Object?>{
          'activityId': 'activity_123',
          'summaryId': 'summary_123',
          'progressionEventId': 'progression_123',
          'validationStatus': 'validated',
          'runSummary': <String, Object?>{
            'title': 'Repository Result Route',
            'startedAt': '2026-06-14T07:00:00.000Z',
            'endedAt': '2026-06-14T07:25:00.000Z',
            'distanceMeters': 3200,
            'durationSeconds': 1500,
            'averagePaceSecondsPerKm': 469,
            'displayDistance': '3.20 km',
            'displayDuration': '25:00',
            'displayPace': '469 sec/km',
            'routeLabel': 'Repository Result Route',
          },
          'progressionDisplay': <String, Object?>{
            'xpDelta': 0,
            'countsTowardLeaderboard': false,
            'status': 'deferred',
            'reason': 'progression_formula_deferred',
          },
          'message': 'Run completion accepted by emulator backend skeleton.',
        },
      );
      final repository = FirebaseRunRepository(callable: callable);

      final result = await repository.completeRun(_payload());

      expect(result.activityId, 'activity_123');
      expect(result.summaryId, 'summary_123');
      expect(result.progressionEventId, 'progression_123');
      expect(result.validationStatus, 'validated');
      expect(result.summary.title, 'Repository Result Route');
      expect(result.summary.distanceKm, '3.20');
      expect(result.summary.duration, '25:00');
      expect(result.summary.avgPace, '7’49”');
      expect(result.progressionDisplay.xpDelta, 0);
      expect(result.progressionDisplay.countsTowardLeaderboard, isFalse);
      expect(result.progressionDisplay.status, 'deferred');
      expect(result.progressionDisplay.reason, 'progression_formula_deferred');
      expect(
        result.message,
        'Run completion accepted by emulator backend skeleton.',
      );
    });

    test(
      'maps zero pace callable response to unavailable pace label',
      () async {
        final response = _minimalCallableResponse();
        final summary =
            Map<String, Object?>.from(
                response['runSummary']! as Map<String, Object?>,
              )
              ..['distanceMeters'] = 0
              ..['durationSeconds'] = 0
              ..['averagePaceSecondsPerKm'] = 0;
        final callable = _FakeCompleteRunCallable(
          response: <String, Object?>{...response, 'runSummary': summary},
        );
        final repository = FirebaseRunRepository(callable: callable);

        final result = await repository.completeRun(_payload());

        expect(result.summary.distanceKm, '0.00');
        expect(result.summary.duration, '0:00');
        expect(result.summary.avgPace, '--');
        expect(result.summary.avgHeartRate, '--');
        expect(result.summary.calories, '--');
      },
    );

    test('maps transient callable failures to retryable completion errors', () {
      const retryableCodes = <String>[
        'unavailable',
        'deadline-exceeded',
        'internal',
      ];

      for (final code in retryableCodes) {
        final repository = FirebaseRunRepository(
          callable: _FakeCompleteRunCallable(errorCode: code),
        );

        expect(
          () => repository.completeRun(_payload()),
          throwsA(
            isA<RunCompletionException>()
                .having((error) => error.code, 'code', code)
                .having((error) => error.isRetryable, 'isRetryable', isTrue),
          ),
        );
      }
    });

    test('maps invalid argument to non-retryable validation error', () {
      final repository = FirebaseRunRepository(
        callable: _FakeCompleteRunCallable(errorCode: 'invalid-argument'),
      );

      expect(
        () => repository.completeRun(_payload()),
        throwsA(
          isA<RunCompletionException>()
              .having((error) => error.code, 'code', 'invalid-argument')
              .having((error) => error.isRetryable, 'isRetryable', isFalse),
        ),
      );
    });

    test(
      'does not add protected backend-owned fields to callable request',
      () async {
        final callable = _FakeCompleteRunCallable(
          response: _minimalCallableResponse(),
        );
        final repository = FirebaseRunRepository(callable: callable);

        await repository.completeRun(_payload());

        const protectedFragments = <String>[
          'xp',
          'streak',
          'level',
          'rank',
          'leaderboard',
          'validation',
          'subscription',
          'userRole',
        ];
        for (final key in callable.lastRequest.keys) {
          for (final fragment in protectedFragments) {
            expect(
              key.toLowerCase(),
              isNot(contains(fragment.toLowerCase())),
              reason: 'request key $key contains protected fragment $fragment',
            );
          }
        }
      },
    );
  });
}

LocalRunCompletionPayload _payload() {
  return LocalRunCompletionPayload(
    clientRunSessionId: 'local-session-20260614-0700',
    startedAt: DateTime.utc(2026, 6, 14, 7),
    completedAt: DateTime.utc(2026, 6, 14, 7, 25),
    durationSeconds: 1500,
    distanceMeters: 3200,
    avgPaceSecondsPerKm: 469,
    source: 'local_simulation',
    routePrivacy: 'private',
    routeLabel: 'Repository Result Route',
    clientAppVersion: 'm5-test',
  );
}

Map<String, Object?> _minimalCallableResponse() {
  return <String, Object?>{
    'activityId': 'activity_123',
    'summaryId': 'summary_123',
    'progressionEventId': 'progression_123',
    'validationStatus': 'validated',
    'runSummary': <String, Object?>{
      'title': 'Completed Run',
      'startedAt': '2026-06-14T07:00:00.000Z',
      'endedAt': '2026-06-14T07:25:00.000Z',
      'distanceMeters': 3200,
      'durationSeconds': 1500,
      'averagePaceSecondsPerKm': 469,
      'displayDistance': '3.20 km',
      'displayDuration': '25:00',
      'displayPace': '469 sec/km',
    },
    'progressionDisplay': <String, Object?>{
      'xpDelta': 0,
      'countsTowardLeaderboard': false,
      'status': 'deferred',
      'reason': 'progression_formula_deferred',
    },
    'message': 'Accepted.',
  };
}

class _FakeCompleteRunCallable implements CompleteRunCallable {
  _FakeCompleteRunCallable({this.response, this.errorCode});

  final Map<String, Object?>? response;
  final String? errorCode;
  Map<String, Object?> lastRequest = <String, Object?>{};

  @override
  Future<Map<String, Object?>> call(Map<String, Object?> request) async {
    lastRequest = request;
    final code = errorCode;
    if (code != null) {
      throw CompleteRunCallableException(code: code, message: 'Failed.');
    }

    return response ?? _minimalCallableResponse();
  }
}
