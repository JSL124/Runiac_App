import '../../domain/models/pace_graph_snapshot.dart';
import '../../domain/services/pace_graph_data_builder.dart';

const normalEasyRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 492),
  PaceGraphSample(elapsedSeconds: 130, paceSecondsPerKm: 486),
  PaceGraphSample(elapsedSeconds: 260, paceSecondsPerKm: 474),
  PaceGraphSample(elapsedSeconds: 390, paceSecondsPerKm: 480),
  PaceGraphSample(elapsedSeconds: 520, paceSecondsPerKm: 496),
  PaceGraphSample(elapsedSeconds: 650, paceSecondsPerKm: 488),
  PaceGraphSample(elapsedSeconds: 780, paceSecondsPerKm: 462),
];

const gpsSpikeRunPaceSamples = [
  PaceGraphSample(elapsedSeconds: 0, paceSecondsPerKm: 500),
  PaceGraphSample(elapsedSeconds: 120, paceSecondsPerKm: 492),
  PaceGraphSample(elapsedSeconds: 240, paceSecondsPerKm: 80),
  PaceGraphSample(elapsedSeconds: 360, paceSecondsPerKm: 484),
  PaceGraphSample(elapsedSeconds: 480, paceSecondsPerKm: 2700),
  PaceGraphSample(elapsedSeconds: 600, paceSecondsPerKm: 476),
  PaceGraphSample(elapsedSeconds: 720, paceSecondsPerKm: 468),
  PaceGraphSample(elapsedSeconds: 840, paceSecondsPerKm: 460),
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
      paceSecondsPerKm: 492,
      displayLabel: '8:12',
    ),
    PaceGraphPoint(
      elapsedSeconds: 130,
      progressFraction: 0.16666666666666666,
      paceSecondsPerKm: 486,
      displayLabel: '8:06',
    ),
    PaceGraphPoint(
      elapsedSeconds: 260,
      progressFraction: 0.3333333333333333,
      paceSecondsPerKm: 474,
      displayLabel: '7:54',
    ),
    PaceGraphPoint(
      elapsedSeconds: 390,
      progressFraction: 0.5,
      paceSecondsPerKm: 480,
      displayLabel: '8:00',
    ),
    PaceGraphPoint(
      elapsedSeconds: 520,
      progressFraction: 0.6666666666666666,
      paceSecondsPerKm: 496,
      displayLabel: '8:16',
    ),
    PaceGraphPoint(
      elapsedSeconds: 650,
      progressFraction: 0.8333333333333334,
      paceSecondsPerKm: 488,
      displayLabel: '8:08',
    ),
    PaceGraphPoint(
      elapsedSeconds: 780,
      progressFraction: 1,
      paceSecondsPerKm: 462,
      displayLabel: '7:42',
    ),
  ],
  yAxisLabels: ['7:20', '8:00', '8:40'],
  xAxisLabels: ['0:00', '6:30', '13:00'],
);

final gpsSpikeRunPaceGraph = const PaceGraphDataBuilder().build(
  samples: gpsSpikeRunPaceSamples,
  durationSeconds: 840,
  distanceMeters: 1700,
);

const unavailablePaceGraph = PaceGraphSnapshot.unavailable();
