import 'run_source_display.dart';

enum ImportedWorkoutActivityType { running }

class ImportedWorkoutCandidate {
  ImportedWorkoutCandidate({
    required this.externalId,
    required this.sourceType,
    required this.activityType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.avgPaceSecondsPerKm,
    required this.calories,
    required this.heartRateAvailability,
    required this.importedAt,
    this.avgHeartRateBpm,
    this.maxHeartRateBpm,
  }) : assert(durationSeconds > 0),
       assert(distanceMeters > 0),
       assert(avgPaceSecondsPerKm > 0),
       assert(calories >= 0),
       assert(
         heartRateAvailability.isAvailable == (avgHeartRateBpm != null),
         'Available heart rate candidates must include avgHeartRateBpm.',
       ),
       assert(
         heartRateAvailability.isAvailable || maxHeartRateBpm == null,
         'Unavailable heart rate candidates must not include maxHeartRateBpm.',
       ),
       assert(!endedAt.isBefore(startedAt));

  final String externalId;
  final RunSourceType sourceType;
  final ImportedWorkoutActivityType activityType;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int distanceMeters;
  final int avgPaceSecondsPerKm;
  final int calories;
  final HeartRateAvailability heartRateAvailability;
  final DateTime importedAt;
  final int? avgHeartRateBpm;
  final int? maxHeartRateBpm;

  String get sourceLabel => sourceType.label;

  String get avgHeartRateDisplay {
    if (!heartRateAvailability.isAvailable || avgHeartRateBpm == null) {
      return '--';
    }
    return '$avgHeartRateBpm bpm';
  }

  String? get heartRateHelperText {
    if (heartRateAvailability.isAvailable && avgHeartRateBpm != null) {
      return null;
    }
    return heartRateAvailability.helperText;
  }
}
