import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/local_run_completion_payload.dart';
import 'package:runiac_app/features/run/domain/models/run_completion_request_adapter.dart';
import 'package:runiac_app/features/run/domain/services/pace_graph_data_builder.dart';

void main() {
  group('RunCompletionRequestAdapter', () {
    test('converts local completion payload to backend-shaped request', () {
      final payload = LocalRunCompletionPayload(
        clientRunSessionId: 'local-session-20260614-0700',
        startedAt: DateTime.utc(2026, 6, 14, 7),
        completedAt: DateTime.utc(2026, 6, 14, 7, 25),
        durationSeconds: 1500,
        distanceMeters: 3200,
        avgPaceSecondsPerKm: 469,
        source: 'local_simulation',
        routePrivacy: 'private',
        routeLabel: 'Repository Result Route',
        clientAppVersion: 'm3-test',
      );

      final request = RunCompletionRequestAdapter.toBackendRequest(payload);

      expect(request['clientRunSessionId'], 'local-session-20260614-0700');
      expect(request['startedAt'], '2026-06-14T07:00:00.000Z');
      expect(request['completedAt'], '2026-06-14T07:25:00.000Z');
      expect(request['durationSeconds'], 1500);
      expect(request['distanceMeters'], 3200);
      expect(request['avgPaceSecondsPerKm'], 469);
      expect(request['source'], 'mobile');
      expect(request['routePrivacy'], 'private');
      expect(request['routeLabel'], 'Repository Result Route');
      expect(request['clientAppVersion'], 'm3-test');
    });

    test('excludes protected backend-owned and governance fields', () {
      final payload = LocalRunCompletionPayload(
        clientRunSessionId: 'local-session-protected-check',
        startedAt: DateTime.utc(2026, 6, 14, 7),
        completedAt: DateTime.utc(2026, 6, 14, 7, 25),
        durationSeconds: 1500,
        distanceMeters: 3200,
        avgPaceSecondsPerKm: 469,
        source: 'local_simulation',
        routePrivacy: 'private',
      );

      final request = RunCompletionRequestAdapter.toBackendRequest(payload);
      const forbiddenFragments = <String>[
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

      for (final key in request.keys) {
        for (final fragment in forbiddenFragments) {
          expect(
            key.toLowerCase(),
            isNot(contains(fragment.toLowerCase())),
            reason: 'request key $key contains protected fragment $fragment',
          );
        }
      }
    });

    test('excludes local-only pace graph samples from backend request', () {
      final payload = LocalRunCompletionPayload(
        clientRunSessionId: 'local-session-graph-request-boundary',
        startedAt: DateTime.utc(2026, 6, 14, 7),
        completedAt: DateTime.utc(2026, 6, 14, 7, 3),
        durationSeconds: 180,
        distanceMeters: 450,
        avgPaceSecondsPerKm: 400,
        source: 'local_simulation',
        routePrivacy: 'private',
        paceGraphSamples: const [
          PaceGraphSample(elapsedSeconds: 60, paceSecondsPerKm: 400),
          PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 402),
          PaceGraphSample(elapsedSeconds: 180, paceSecondsPerKm: 398),
        ],
      );

      final request = RunCompletionRequestAdapter.toBackendRequest(payload);
      const forbiddenKeys = <String>[
        'paceGraphSamples',
        'graphSamples',
        'paceGraph',
        'paceGraphPoints',
        'samples',
      ];

      for (final key in forbiddenKeys) {
        expect(request.keys, isNot(contains(key)));
      }
      expect(request.values.join(' '), isNot(contains('paceGraphSamples')));
      expect(request.values.join(' '), isNot(contains('paceGraph')));
    });
  });
}
