import '../../../run/domain/models/run_activity_display_model.dart';
import '../../../run/domain/models/cadence_analysis_series.dart';
import '../../../run/domain/models/pace_analysis_series.dart';
import '../../../run/domain/models/run_source_display.dart';
import '../../../run/domain/models/run_summary_snapshot.dart';
import '../../../run/presentation/data/pace_graph_demo_snapshots.dart';

// Display-only activity history for the static You prototype.
final activityHistoryDisplayData = [
  ActivityHistoryMonth(
    label: 'June 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'Pace Graph QA Run',
        timeAgoLabel: 'Today · Manual QA',
        distanceLabel: '1.10 km',
        paceLabel: '7\'16"',
        durationLabel: '8:00',
        summary: RunSummarySnapshot(
          title: 'Pace Graph QA Run',
          dateLabel: 'Today',
          timeLabel: 'Manual QA',
          distanceKm: '1.10',
          avgPace: '7\'16"',
          duration: '8:00',
          avgHeartRate: '--',
          calories: '--',
          routeName: 'Manual Pace Graph Check',
          sourceType: RunSourceType.runiacGps,
          heartRateAvailability: HeartRateAvailability.unavailableNotShared,
          paceAnalysisSeries: PaceAnalysisSeries.localAccepted(
            samples: [
              PaceAnalysisSample.accepted(
                elapsedSeconds: 60,
                cumulativeDistanceMeters: 100,
                paceSecondsPerKm: 428,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 120,
                cumulativeDistanceMeters: 250,
                paceSecondsPerKm: 432,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 180,
                cumulativeDistanceMeters: 450,
                paceSecondsPerKm: 444,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 240,
                cumulativeDistanceMeters: 700,
                paceSecondsPerKm: 456,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 300,
                cumulativeDistanceMeters: 780,
                paceSecondsPerKm: 448,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 360,
                cumulativeDistanceMeters: 850,
                paceSecondsPerKm: 438,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 420,
                cumulativeDistanceMeters: 980,
                paceSecondsPerKm: 430,
              ),
              PaceAnalysisSample.accepted(
                elapsedSeconds: 480,
                cumulativeDistanceMeters: 1100,
                paceSecondsPerKm: 425,
              ),
            ],
          ),
          cadenceAnalysisSeries: CadenceAnalysisSeries.localAccepted(
            samples: const [
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 0,
                cadenceSpm: 173,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 120,
                cadenceSpm: 170,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 240,
                cadenceSpm: 172,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 360,
                cadenceSpm: 174,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 480,
                cadenceSpm: 176,
              ),
            ],
          ),
          paceGraph: paceGraphManualQaAvailableGraph,
        ),
      ),
      RunActivityDisplayModel(
        title: 'Easy Morning Jog',
        timeAgoLabel: '4 Jun 2026',
        distanceLabel: '4.03 km',
        paceLabel: '6\'30"',
        durationLabel: '30:15',
        summary: RunSummarySnapshot(
          title: 'Easy Morning Jog',
          dateLabel: '4 Jun 2026',
          timeLabel: '6:45 AM',
          distanceKm: '4.03',
          avgPace: '6\'30"',
          duration: '30:15',
          avgHeartRate: '138',
          calories: '242',
          routeName: 'Neighbourhood Easy Loop',
          sourceType: RunSourceType.garminViaHealth,
          heartRateAvailability: HeartRateAvailability.available,
          paceGraph: easyMorningHistoryPaceGraph,
        ),
      ),
      RunActivityDisplayModel(
        title: 'Riverside Recovery',
        timeAgoLabel: '1 Jun 2026',
        distanceLabel: '0.06 km',
        paceLabel: '--',
        durationLabel: '00:38',
        summary: RunSummarySnapshot(
          title: 'Riverside Recovery',
          dateLabel: '1 Jun 2026',
          timeLabel: '7:05 PM',
          distanceKm: '0.06',
          avgPace: '--',
          duration: '00:38',
          avgHeartRate: '--',
          calories: '--',
          routeName: 'Riverside Start Check',
          hasSufficientData: false,
          sourceType: RunSourceType.healthConnect,
          heartRateAvailability: HeartRateAvailability.unavailableNotShared,
          paceGraph: unavailablePaceGraph,
        ),
      ),
    ],
  ),
  ActivityHistoryMonth(
    label: 'May 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'Sunset Loop',
        timeAgoLabel: '28 May 2026',
        distanceLabel: '4.50 km',
        paceLabel: '6\'52"',
        durationLabel: '30:54',
        summary: RunSummarySnapshot(
          title: 'Sunset Loop',
          dateLabel: '28 May 2026',
          timeLabel: '6:12 PM',
          distanceKm: '4.50',
          avgPace: '6\'52"',
          duration: '30:54',
          avgHeartRate: '140',
          calories: '270',
          routeName: 'Sunset Park Loop',
          sourceType: RunSourceType.demoImport,
          heartRateAvailability: HeartRateAvailability.available,
        ),
      ),
      RunActivityDisplayModel(
        title: 'Tuesday Tempo',
        timeAgoLabel: '20 May 2026',
        distanceLabel: '5.00 km',
        paceLabel: '6\'20"',
        durationLabel: '31:40',
        summary: RunSummarySnapshot(
          title: 'Tuesday Tempo',
          dateLabel: '20 May 2026',
          timeLabel: '7:10 PM',
          distanceKm: '5.00',
          avgPace: '6\'20"',
          duration: '31:40',
          avgHeartRate: '148',
          calories: '310',
          routeName: 'Tempo Training Loop',
          sourceType: RunSourceType.demoImport,
          heartRateAvailability: HeartRateAvailability.available,
        ),
      ),
      RunActivityDisplayModel(
        title: 'Park Walk + Run',
        timeAgoLabel: '12 May 2026',
        distanceLabel: '3.80 km',
        paceLabel: '7\'10"',
        durationLabel: '27:14',
        summary: RunSummarySnapshot(
          title: 'Park Walk + Run',
          dateLabel: '12 May 2026',
          timeLabel: '6:40 PM',
          distanceKm: '3.80',
          avgPace: '7\'10"',
          duration: '27:14',
          avgHeartRate: '134',
          calories: '220',
          routeName: 'Neighbourhood Park Loop',
          sourceType: RunSourceType.demoImport,
          heartRateAvailability: HeartRateAvailability.available,
        ),
      ),
    ],
  ),
  ActivityHistoryMonth(
    label: 'April 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'First 5K Attempt',
        timeAgoLabel: '25 Apr 2026',
        distanceLabel: '5.00 km',
        paceLabel: '7\'25"',
        durationLabel: '37:05',
        summary: RunSummarySnapshot(
          title: 'First 5K Attempt',
          dateLabel: '25 Apr 2026',
          timeLabel: '8:02 AM',
          distanceKm: '5.00',
          avgPace: '7\'25"',
          duration: '37:05',
          avgHeartRate: '142',
          calories: '298',
          routeName: 'First 5K Practice Loop',
          sourceType: RunSourceType.demoImport,
          heartRateAvailability: HeartRateAvailability.available,
        ),
      ),
      RunActivityDisplayModel(
        title: 'Gentle Start',
        timeAgoLabel: '14 Apr 2026',
        distanceLabel: '2.50 km',
        paceLabel: '7\'40"',
        durationLabel: '19:10',
        summary: RunSummarySnapshot(
          title: 'Gentle Start',
          dateLabel: '14 Apr 2026',
          timeLabel: '7:20 AM',
          distanceKm: '2.50',
          avgPace: '7\'40"',
          duration: '19:10',
          avgHeartRate: '128',
          calories: '150',
          routeName: 'Gentle Starter Loop',
          sourceType: RunSourceType.demoImport,
          heartRateAvailability: HeartRateAvailability.available,
        ),
      ),
    ],
  ),
];

class ActivityHistoryMonth {
  const ActivityHistoryMonth({required this.label, required this.activities});

  final String label;
  final List<RunActivityDisplayModel> activities;
}
