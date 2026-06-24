import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/static_run_repository.dart';
import 'package:runiac_app/features/run/domain/models/advanced_analysis_snapshot.dart';
import 'package:runiac_app/features/run/domain/models/run_location_sample.dart';
import 'package:runiac_app/features/run/domain/repositories/run_cadence_provider.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_provider.dart';
import 'package:runiac_app/features/run/domain/services/advanced_analysis_snapshot_builder.dart';
import 'package:runiac_app/features/run/presentation/controllers/run_tracking_controller.dart';

void main() {
  group('Run tracking cadence provider flow', () {
    test(
      'fake phone cadence reaches local summary and Advanced Analysis',
      () async {
        final startedAt = DateTime.utc(2026, 6, 24, 7);
        final cadenceProvider = FakeRunCadenceProvider(
          cadencePattern: const <double>[168, 170, 172],
        );
        final controller = RunTrackingController(
          cadenceProvider: cadenceProvider,
          locationProvider: _replayLocationProvider(startedAt),
        );

        controller.start(
          startedAt: startedAt,
          clientRunSessionId: 'cadence-flow',
        );
        await Future<void>.delayed(Duration.zero);
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 10)),
        );
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 20)),
        );
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 30)),
        );
        await Future<void>.delayed(Duration.zero);
        controller.advanceBy(const Duration(seconds: 180));

        final payload = controller.completionPayload(
          completedAt: startedAt.add(const Duration(seconds: 180)),
        );
        final completedRun = await const StaticRunRepository().completeRun(
          payload,
        );
        final cadence = const AdvancedAnalysisSnapshotBuilder()
            .fromRunSummary(completedRun.summary)
            .formCadence;

        expect(payload.toRawClientMap().keys, isNot(contains('cadence')));
        expect(
          payload.cadenceAnalysisSeries?.validAcceptedSamples,
          hasLength(3),
        );
        expect(
          completedRun.summary.cadenceAnalysisSeries?.source.name,
          'phoneSensorEstimated',
        );
        expect(cadence.averageCadence.valueLabel, '170 spm');
        expect(
          cadence.averageCadence.source,
          AdvancedAnalysisMetricSource.phoneSensorEstimated,
        );
        expect(cadence.cadenceGraph.isAvailable, isTrue);

        await cadenceProvider.dispose();
      },
    );

    test(
      'paused run ignores cadence emitted outside active lifecycle',
      () async {
        final startedAt = DateTime.utc(2026, 6, 24, 7);
        final cadenceProvider = FakeRunCadenceProvider(
          cadencePattern: const <double>[168, 170, 172],
        );
        final controller = RunTrackingController(
          cadenceProvider: cadenceProvider,
          locationProvider: _replayLocationProvider(startedAt),
        );

        controller.start(startedAt: startedAt);
        await Future<void>.delayed(Duration.zero);
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 10)),
        );
        await Future<void>.delayed(Duration.zero);
        controller.pause(pausedAt: startedAt.add(const Duration(seconds: 20)));
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 25)),
        );
        await Future<void>.delayed(Duration.zero);
        controller.resume(
          resumedAt: startedAt.add(const Duration(seconds: 40)),
        );
        await Future<void>.delayed(Duration.zero);
        cadenceProvider.emitNext(
          recordedAt: startedAt.add(const Duration(seconds: 50)),
        );
        await Future<void>.delayed(Duration.zero);

        final payload = controller.completionPayload(
          completedAt: startedAt.add(const Duration(seconds: 120)),
        );

        expect(
          payload.cadenceAnalysisSeries?.validAcceptedSamples,
          hasLength(2),
        );

        await cadenceProvider.dispose();
      },
    );

    test('unavailable provider leaves cadence analysis unavailable', () {
      final startedAt = DateTime.utc(2026, 6, 24, 7);
      final controller = RunTrackingController(
        cadenceProvider: const UnavailableRunCadenceProvider(),
        locationProvider: _replayLocationProvider(startedAt),
      );

      controller.start(startedAt: startedAt);
      controller.advanceBy(const Duration(seconds: 180));
      final payload = controller.completionPayload(
        completedAt: startedAt.add(const Duration(seconds: 180)),
      );

      expect(payload.cadenceAnalysisSeries, isNull);
    });
  });
}

RunLocationProvider _replayLocationProvider(DateTime startedAt) {
  return ReplayRunLocationProvider([
    RunLocationReplaySample(
      activeOffset: Duration.zero,
      sample: RunLocationSample(
        recordedAt: startedAt,
        latitude: 1.300000,
        longitude: 103.800000,
      ),
    ),
    RunLocationReplaySample(
      activeOffset: const Duration(seconds: 60),
      sample: RunLocationSample(
        recordedAt: startedAt.add(const Duration(seconds: 60)),
        latitude: 1.301349,
        longitude: 103.800000,
      ),
    ),
    RunLocationReplaySample(
      activeOffset: const Duration(seconds: 120),
      sample: RunLocationSample(
        recordedAt: startedAt.add(const Duration(seconds: 120)),
        latitude: 1.302698,
        longitude: 103.800000,
      ),
    ),
    RunLocationReplaySample(
      activeOffset: const Duration(seconds: 180),
      sample: RunLocationSample(
        recordedAt: startedAt.add(const Duration(seconds: 180)),
        latitude: 1.304047,
        longitude: 103.800000,
      ),
    ),
  ]);
}
