import '../../domain/models/pace_graph_snapshot.dart';
import '../../domain/services/pace_graph_data_builder.dart';

const normalEasyRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 405),
  PaceGraphSample(elapsedSeconds: 300, paceSecondsPerKm: 398),
  PaceGraphSample(elapsedSeconds: 600, paceSecondsPerKm: 392),
  PaceGraphSample(elapsedSeconds: 900, paceSecondsPerKm: 388),
  PaceGraphSample(elapsedSeconds: 1200, paceSecondsPerKm: 394),
  PaceGraphSample(elapsedSeconds: 1500, paceSecondsPerKm: 386),
  PaceGraphSample(elapsedSeconds: 1770, paceSecondsPerKm: 382),
];

const gpsSpikeRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 440),
  PaceGraphSample(elapsedSeconds: 240, paceSecondsPerKm: 432),
  PaceGraphSample(elapsedSeconds: 360, paceSecondsPerKm: 80),
  PaceGraphSample(elapsedSeconds: 600, paceSecondsPerKm: 426),
  PaceGraphSample(elapsedSeconds: 840, paceSecondsPerKm: 2700),
  PaceGraphSample(elapsedSeconds: 1080, paceSecondsPerKm: 420),
  PaceGraphSample(elapsedSeconds: 1320, paceSecondsPerKm: 414),
  PaceGraphSample(elapsedSeconds: 1410, paceSecondsPerKm: 410),
];

const lowDataRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 540),
  PaceGraphSample(elapsedSeconds: 30, paceSecondsPerKm: 560),
];

const tooFewValidPointsRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 90),
  PaceGraphSample(elapsedSeconds: 80, paceSecondsPerKm: 510),
  PaceGraphSample(elapsedSeconds: 160, paceSecondsPerKm: 2600),
  PaceGraphSample(elapsedSeconds: 240, paceSecondsPerKm: 520),
  PaceGraphSample(elapsedSeconds: 320, paceSecondsPerKm: 70),
];

const slowWalkOrPauseRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 1180),
  PaceGraphSample(elapsedSeconds: 180, paceSecondsPerKm: 1320),
  PaceGraphSample(elapsedSeconds: 360, paceSecondsPerKm: 1900),
  PaceGraphSample(elapsedSeconds: 540, paceSecondsPerKm: 1500),
  PaceGraphSample(elapsedSeconds: 720, paceSecondsPerKm: 1810),
  PaceGraphSample(elapsedSeconds: 900, paceSecondsPerKm: 1580),
];

const progressiveRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 520),
  PaceGraphSample(elapsedSeconds: 150, paceSecondsPerKm: 508),
  PaceGraphSample(elapsedSeconds: 300, paceSecondsPerKm: 496),
  PaceGraphSample(elapsedSeconds: 450, paceSecondsPerKm: 484),
  PaceGraphSample(elapsedSeconds: 600, paceSecondsPerKm: 472),
  PaceGraphSample(elapsedSeconds: 750, paceSecondsPerKm: 460),
];

const normalEasyRunPaceGraph = PaceGraphSnapshot(
  isAvailable: true,
  points: [
    PaceGraphPoint(
      elapsedSeconds: 0,
      progressFraction: 0,
      paceSecondsPerKm: 405,
      displayLabel: '6:45',
    ),
    PaceGraphPoint(
      elapsedSeconds: 300,
      progressFraction: 0.1652892561983471,
      paceSecondsPerKm: 398,
      displayLabel: '6:38',
    ),
    PaceGraphPoint(
      elapsedSeconds: 600,
      progressFraction: 0.3305785123966942,
      paceSecondsPerKm: 392,
      displayLabel: '6:32',
    ),
    PaceGraphPoint(
      elapsedSeconds: 900,
      progressFraction: 0.49586776859504134,
      paceSecondsPerKm: 388,
      displayLabel: '6:28',
    ),
    PaceGraphPoint(
      elapsedSeconds: 1200,
      progressFraction: 0.6611570247933884,
      paceSecondsPerKm: 394,
      displayLabel: '6:34',
    ),
    PaceGraphPoint(
      elapsedSeconds: 1500,
      progressFraction: 0.8264462809917356,
      paceSecondsPerKm: 386,
      displayLabel: '6:26',
    ),
    PaceGraphPoint(
      elapsedSeconds: 1770,
      progressFraction: 0.9752066115702479,
      paceSecondsPerKm: 382,
      displayLabel: '6:22',
    ),
  ],
  yAxisLabels: ['6:00', '6:40', '7:20'],
  xAxisLabels: ['0:00', '10:00', '20:00', '30:15'],
  totalDurationSeconds: 1815,
  averagePaceSecondsPerKm: 390,
  bestPacePoint: PaceGraphPoint(
    elapsedSeconds: 1770,
    progressFraction: 0.9752066115702479,
    paceSecondsPerKm: 382,
    displayLabel: '6:22',
  ),
  slowestPacePoint: PaceGraphPoint(
    elapsedSeconds: 0,
    progressFraction: 0,
    paceSecondsPerKm: 405,
    displayLabel: '6:45',
  ),
  paceRangeMinSecondsPerKm: 360,
  paceRangeMaxSecondsPerKm: 440,
);

final gpsSpikeRunPaceGraph = const PaceGraphDataBuilder().build(
  samples: gpsSpikeRunPaceSamples,
  durationSeconds: 1450,
  distanceMeters: 3200,
  averagePaceSecondsPerKm: 425,
);

PaceGraphSnapshot buildDemoPaceGraph({
  required List<PaceGraphSample> samples,
  required int durationSeconds,
  required int distanceMeters,
  int? averagePaceSecondsPerKm,
}) {
  return const PaceGraphDataBuilder().build(
    samples: samples,
    durationSeconds: durationSeconds,
    distanceMeters: distanceMeters,
    averagePaceSecondsPerKm: averagePaceSecondsPerKm,
  );
}

final saturdayNightRecentPaceGraph = normalEasyRunPaceGraph;

final morningEasyRecentPaceGraph = gpsSpikeRunPaceGraph;

final recoveryJogPaceGraph = buildDemoPaceGraph(
  samples: progressiveRunPaceSamples,
  durationSeconds: 2378,
  distanceMeters: 5170,
  averagePaceSecondsPerKm: 460,
);

final saturdayNightHistoryPaceGraph = buildDemoPaceGraph(
  samples: normalEasyRunPaceSamples,
  durationSeconds: 2072,
  distanceMeters: 5120,
  averagePaceSecondsPerKm: 405,
);

final easyMorningHistoryPaceGraph = buildDemoPaceGraph(
  samples: gpsSpikeRunPaceSamples,
  durationSeconds: 1815,
  distanceMeters: 4030,
  averagePaceSecondsPerKm: 390,
);

const unavailablePaceGraph = PaceGraphSnapshot.unavailable();
