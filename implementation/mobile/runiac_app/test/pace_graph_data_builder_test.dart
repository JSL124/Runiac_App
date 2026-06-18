import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/services/pace_graph_data_builder.dart';
import 'package:runiac_app/features/run/presentation/data/pace_graph_demo_snapshots.dart';

void main() {
  group('PaceGraphDataBuilder', () {
    const builder = PaceGraphDataBuilder();

    test(
      'normal easy run returns available graph with normalized progress',
      () {
        final graph = builder.build(
          samples: normalEasyRunPaceSamples,
          durationSeconds: 1815,
          distanceMeters: 4030,
          averagePaceSecondsPerKm: 390,
        );

        expect(graph.isAvailable, isTrue);
        expect(graph.points.length, greaterThanOrEqualTo(3));
        expect(graph.points.first.progressFraction, 0);
        expect(graph.points.last.progressFraction, closeTo(1770 / 1815, 0.001));
        expect(
          graph.points.every(
            (point) =>
                point.progressFraction >= 0 && point.progressFraction <= 1,
          ),
          isTrue,
        );
        expect(graph.totalDurationSeconds, 1815);
        expect(graph.averagePaceSecondsPerKm, 390);
        expect(graph.bestPacePoint?.paceSecondsPerKm, 382);
        expect(graph.slowestPacePoint?.paceSecondsPerKm, 405);
        expect(graph.paceRangeMinSecondsPerKm, 360);
        expect(graph.paceRangeMaxSecondsPerKm, 440);
      },
    );

    test('normal easy fixture graph matches builder output', () {
      final graph = builder.build(
        samples: normalEasyRunPaceSamples,
        durationSeconds: 1815,
        distanceMeters: 4030,
        averagePaceSecondsPerKm: 390,
      );

      expect(graph.isAvailable, normalEasyRunPaceGraph.isAvailable);
      expect(graph.xAxisLabels, normalEasyRunPaceGraph.xAxisLabels);
      expect(graph.yAxisLabels, normalEasyRunPaceGraph.yAxisLabels);
      expect(
        graph.totalDurationSeconds,
        normalEasyRunPaceGraph.totalDurationSeconds,
      );
      expect(
        graph.averagePaceSecondsPerKm,
        normalEasyRunPaceGraph.averagePaceSecondsPerKm,
      );
      expect(
        graph.bestPacePoint?.paceSecondsPerKm,
        normalEasyRunPaceGraph.bestPacePoint?.paceSecondsPerKm,
      );
      expect(
        graph.slowestPacePoint?.paceSecondsPerKm,
        normalEasyRunPaceGraph.slowestPacePoint?.paceSecondsPerKm,
      );
      expect(
        graph.paceRangeMinSecondsPerKm,
        normalEasyRunPaceGraph.paceRangeMinSecondsPerKm,
      );
      expect(
        graph.paceRangeMaxSecondsPerKm,
        normalEasyRunPaceGraph.paceRangeMaxSecondsPerKm,
      );
      expect(
        graph.points.map((point) => point.elapsedSeconds),
        normalEasyRunPaceGraph.points.map((point) => point.elapsedSeconds),
      );
      expect(
        graph.points.map((point) => point.paceSecondsPerKm),
        normalEasyRunPaceGraph.points.map((point) => point.paceSecondsPerKm),
      );
      expect(
        graph.points.map((point) => point.progressFraction),
        normalEasyRunPaceGraph.points.map((point) => point.progressFraction),
      );
    });

    test('gps spike run filters unrealistic fast and slow pace values', () {
      final graph = builder.build(
        samples: gpsSpikeRunPaceSamples,
        durationSeconds: 1450,
        distanceMeters: 3200,
        averagePaceSecondsPerKm: 425,
      );

      expect(graph.isAvailable, isTrue);
      expect(graph.points.length, greaterThanOrEqualTo(3));
      expect(graph.xAxisLabels, ['0:00', '8:00', '16:00', '24:10']);
      expect(graph.averagePaceSecondsPerKm, 425);
      expect(graph.bestPacePoint?.paceSecondsPerKm, 410);
      expect(graph.slowestPacePoint?.paceSecondsPerKm, 440);
      expect(
        graph.points.any((point) => point.paceSecondsPerKm == 80),
        isFalse,
      );
      expect(
        graph.points.any((point) => point.paceSecondsPerKm == 2700),
        isFalse,
      );
    });

    test('duration-based x axis uses total run time', () {
      final thirtyMinuteGraph = builder.build(
        samples: normalEasyRunPaceSamples,
        durationSeconds: 1815,
        distanceMeters: 4030,
      );
      final twelveMinuteGraph = builder.build(
        samples: normalEasyRunPaceSamples,
        durationSeconds: 720,
        distanceMeters: 1600,
      );

      expect(thirtyMinuteGraph.xAxisLabels, [
        '0:00',
        '10:00',
        '20:00',
        '30:15',
      ]);
      expect(twelveMinuteGraph.xAxisLabels, ['0:00', '6:00', '12:00']);
    });

    test('recovery fixture covers the long summary duration', () {
      expect(recoveryJogPaceGraph.isAvailable, isTrue);
      expect(recoveryJogPaceGraph.xAxisLabels, [
        '0:00',
        '13:00',
        '26:00',
        '39:38',
      ]);
      expect(recoveryJogPaceGraph.points.length, greaterThanOrEqualTo(3));
      expect(recoveryJogPaceGraph.points.last.elapsedSeconds, 2370);
      expect(
        recoveryJogPaceGraph.points.last.progressFraction,
        greaterThan(0.95),
      );
    });

    test('low-data run returns unavailable graph', () {
      final graph = builder.build(
        samples: lowDataRunPaceSamples,
        durationSeconds: 35,
        distanceMeters: 20,
      );

      expect(graph.isAvailable, isFalse);
      expect(graph.points, isEmpty);
      expect(graph.averagePaceSecondsPerKm, isNull);
      expect(graph.bestPacePoint, isNull);
      expect(graph.slowestPacePoint, isNull);
    });

    test('too few valid points run returns unavailable graph', () {
      final graph = builder.build(
        samples: tooFewValidPointsRunPaceSamples,
        durationSeconds: 360,
        distanceMeters: 800,
      );

      expect(graph.isAvailable, isFalse);
      expect(graph.points.length, lessThan(3));
    });

    test('filters threshold and non-increasing elapsed samples', () {
      final graph = builder.build(
        samples: const [
          PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 149),
          PaceGraphSample(elapsedSeconds: 30, paceSecondsPerKm: 450),
          PaceGraphSample(elapsedSeconds: 30, paceSecondsPerKm: 460),
          PaceGraphSample(elapsedSeconds: 20, paceSecondsPerKm: 470),
          PaceGraphSample(elapsedSeconds: 60, paceSecondsPerKm: 1801),
          PaceGraphSample(elapsedSeconds: 90, paceSecondsPerKm: 480),
          PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 490),
        ],
        durationSeconds: 180,
        distanceMeters: 600,
      );

      expect(graph.isAvailable, isTrue);
      expect(graph.points.map((point) => point.paceSecondsPerKm), [
        450,
        480,
        490,
      ]);
      expect(graph.points.map((point) => point.elapsedSeconds), [30, 90, 120]);
    });

    test('pace axis range keeps a minimum visible spread', () {
      final graph = builder.build(
        samples: const [
          PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 390),
          PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 392),
          PaceGraphSample(elapsedSeconds: 240, paceSecondsPerKm: 394),
        ],
        durationSeconds: 300,
        distanceMeters: 1000,
      );

      expect(graph.isAvailable, isTrue);
      expect(
        graph.paceRangeMaxSecondsPerKm! - graph.paceRangeMinSecondsPerKm!,
        greaterThanOrEqualTo(minVisiblePaceRangeSeconds),
      );

      final nearMaxGraph = builder.build(
        samples: const [
          PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 1788),
          PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 1792),
          PaceGraphSample(elapsedSeconds: 240, paceSecondsPerKm: 1796),
        ],
        durationSeconds: 300,
        distanceMeters: 1000,
      );
      expect(
        nearMaxGraph.paceRangeMaxSecondsPerKm! -
            nearMaxGraph.paceRangeMinSecondsPerKm!,
        greaterThanOrEqualTo(minVisiblePaceRangeSeconds),
      );
    });

    test('slow walk or pause run filters over-threshold slow values', () {
      final graph = builder.build(
        samples: slowWalkOrPauseRunPaceSamples,
        durationSeconds: 900,
        distanceMeters: 650,
      );

      expect(graph.isAvailable, isTrue);
      expect(
        graph.points.any((point) => point.paceSecondsPerKm > 1800),
        isFalse,
      );
    });
  });
}
