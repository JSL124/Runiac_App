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
          durationSeconds: 780,
          distanceMeters: 1600,
        );

        expect(graph.isAvailable, isTrue);
        expect(graph.points.length, greaterThanOrEqualTo(3));
        expect(graph.points.first.progressFraction, 0);
        expect(graph.points.last.progressFraction, 1);
        expect(
          graph.points.every(
            (point) =>
                point.progressFraction >= 0 && point.progressFraction <= 1,
          ),
          isTrue,
        );
      },
    );

    test('normal easy fixture graph matches builder output', () {
      final graph = builder.build(
        samples: normalEasyRunPaceSamples,
        durationSeconds: 780,
        distanceMeters: 1600,
      );

      expect(graph.isAvailable, normalEasyRunPaceGraph.isAvailable);
      expect(graph.xAxisLabels, normalEasyRunPaceGraph.xAxisLabels);
      expect(graph.yAxisLabels, normalEasyRunPaceGraph.yAxisLabels);
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
        durationSeconds: 840,
        distanceMeters: 1700,
      );

      expect(graph.isAvailable, isTrue);
      expect(graph.points.length, greaterThanOrEqualTo(3));
      expect(
        graph.points.any((point) => point.paceSecondsPerKm == 80),
        isFalse,
      );
      expect(
        graph.points.any((point) => point.paceSecondsPerKm == 2700),
        isFalse,
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
