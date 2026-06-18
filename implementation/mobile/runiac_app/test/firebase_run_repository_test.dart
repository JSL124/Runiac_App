import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/firebase_run_repository.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_completion_error.dart';
import 'package:runiac_app/features/run/domain/services/pace_graph_data_builder.dart';

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
      expect(result.summary.title, 'Sunday Morning Run');
      expect(result.summary.distanceKm, '3.20');
      expect(result.summary.duration, '25:00');
      expect(result.summary.avgPace, '7’49”');
      expect(result.summary.calories, '270');
      expect(result.summary.hasSufficientData, isTrue);
      expect(result.summary.paceGraph.isAvailable, isFalse);
      expect(result.summary.paceGraph.points, isEmpty);
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
        expect(result.summary.hasSufficientData, isFalse);
      },
    );

    test(
      'maps unreliable callable pace values to unavailable pace label',
      () async {
        const cases = <_SummaryPaceCase>[
          _SummaryPaceCase(
            label: 'short distance',
            distanceMeters: 49,
            durationSeconds: 300,
            paceSecondsPerKm: 360,
            expectedPace: '--',
          ),
          _SummaryPaceCase(
            label: 'short duration',
            distanceMeters: 1000,
            durationSeconds: 59,
            paceSecondsPerKm: 360,
            expectedPace: '--',
          ),
          _SummaryPaceCase(
            label: 'too fast',
            distanceMeters: 1000,
            durationSeconds: 180,
            paceSecondsPerKm: 149,
            expectedPace: '--',
          ),
          _SummaryPaceCase(
            label: 'too slow',
            distanceMeters: 1000,
            durationSeconds: 1900,
            paceSecondsPerKm: 1801,
            expectedPace: '--',
          ),
          _SummaryPaceCase(
            label: 'normal pace',
            distanceMeters: 1000,
            durationSeconds: 450,
            paceSecondsPerKm: 450,
            expectedPace: '7’30”',
          ),
        ];

        for (final testCase in cases) {
          final callable = _FakeCompleteRunCallable(
            response: _callableResponseWithSummary(
              distanceMeters: testCase.distanceMeters,
              durationSeconds: testCase.durationSeconds,
              paceSecondsPerKm: testCase.paceSecondsPerKm,
            ),
          );
          final repository = FirebaseRunRepository(callable: callable);

          final result = await repository.completeRun(_payload());

          expect(
            result.summary.avgPace,
            testCase.expectedPace,
            reason: testCase.label,
          );
          expect(
            result.summary.hasSufficientData,
            testCase.expectedPace != '--',
            reason: testCase.label,
          );
        }
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
          'calorie',
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

    test(
      'does not send local pace graph samples or route data to Firebase callable',
      () async {
        final callable = _FakeCompleteRunCallable(
          response: _minimalCallableResponse(),
        );
        final repository = FirebaseRunRepository(callable: callable);

        final result = await repository.completeRun(
          _payload(
            paceGraphSamples: const <PaceGraphSample>[
              PaceGraphSample(elapsedSeconds: 60, paceSecondsPerKm: 410),
              PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 405),
              PaceGraphSample(elapsedSeconds: 180, paceSecondsPerKm: 408),
            ],
          ),
        );

        expect(callable.lastRequest['durationSeconds'], 1500);
        expect(callable.lastRequest['distanceMeters'], 3200);
        expect(callable.lastRequest['avgPaceSecondsPerKm'], 469);
        expect(callable.lastRequest['source'], 'mobile');
        expect(callable.lastRequest['routePrivacy'], 'private');
        expect(callable.lastRequest['routeLabel'], 'Repository Result Route');
        expect(callable.lastRequest['clientAppVersion'], 'm5-test');
        expect(result.summary.paceGraph.isAvailable, isFalse);
        expect(result.summary.paceGraph.points, isEmpty);

        const forbiddenFragments = <String>[
          'paceGraphSamples',
          'graphSamples',
          'PaceGraphSample',
          'paceGraph',
          'samples',
          'latitude',
          'longitude',
          'routeTrace',
          'polyline',
          'positions',
          'gpsSamples',
          'rawLocationSamples',
          'displayRouteSegments',
          'acceptedRouteSegments',
          'motionEvidence',
          'xp',
          'streak',
          'level',
          'rank',
          'leaderboard',
          'weeklyXp',
          'monthlyXp',
          'subscription',
          'expertPlan',
        ];
        final serializedRequest = callable.lastRequest.entries
            .map((entry) => '${entry.key}:${entry.value}')
            .join('|');
        for (final fragment in forbiddenFragments) {
          expect(
            serializedRequest.toLowerCase(),
            isNot(contains(fragment.toLowerCase())),
            reason: 'callable request leaked forbidden fragment $fragment',
          );
        }
      },
    );
  });
}

LocalRunCompletionPayload _payload({
  List<PaceGraphSample> paceGraphSamples = const <PaceGraphSample>[],
}) {
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
    paceGraphSamples: paceGraphSamples,
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

Map<String, Object?> _callableResponseWithSummary({
  required int distanceMeters,
  required int durationSeconds,
  required int paceSecondsPerKm,
}) {
  final response = _minimalCallableResponse();
  final summary =
      Map<String, Object?>.from(response['runSummary']! as Map<String, Object?>)
        ..['distanceMeters'] = distanceMeters
        ..['durationSeconds'] = durationSeconds
        ..['averagePaceSecondsPerKm'] = paceSecondsPerKm;
  return <String, Object?>{...response, 'runSummary': summary};
}

class _SummaryPaceCase {
  const _SummaryPaceCase({
    required this.label,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceSecondsPerKm,
    required this.expectedPace,
  });

  final String label;
  final int distanceMeters;
  final int durationSeconds;
  final int paceSecondsPerKm;
  final String expectedPace;
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
