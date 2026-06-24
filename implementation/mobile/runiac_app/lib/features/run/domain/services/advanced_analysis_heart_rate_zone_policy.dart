import '../models/advanced_analysis_snapshot.dart';
import '../models/workout_metric_contract.dart';

class AdvancedAnalysisHeartRateZonePolicy {
  const AdvancedAnalysisHeartRateZonePolicy();

  String get targetLabel => '120-169 bpm';

  List<AdvancedAnalysisHeartRateZone> zonesForSamples(
    List<WorkoutMetricSample> samples,
    int? durationSeconds,
  ) {
    if (samples.length < 2) {
      return const <AdvancedAnalysisHeartRateZone>[];
    }
    final totals = List<int>.filled(_zoneCount, 0);
    for (var index = 0; index < samples.length - 1; index += 1) {
      final current = samples[index];
      final next = samples[index + 1];
      final segmentSeconds = next.elapsedSeconds - current.elapsedSeconds;
      if (segmentSeconds <= 0) {
        continue;
      }
      totals[_zoneIndex(current.value.round())] += segmentSeconds;
    }
    final lastSample = samples.last;
    if (durationSeconds != null &&
        durationSeconds > lastSample.elapsedSeconds) {
      totals[_zoneIndex(lastSample.value.round())] +=
          durationSeconds - lastSample.elapsedSeconds;
    }
    final totalSeconds = totals.fold<int>(0, (sum, value) => sum + value);
    if (totalSeconds <= 0) {
      return const <AdvancedAnalysisHeartRateZone>[];
    }
    final zones = <AdvancedAnalysisHeartRateZone>[];
    var assignedPercent = 0;
    for (var index = 0; index < totals.length; index += 1) {
      final percent = index == totals.length - 1
          ? 100 - assignedPercent
          : (totals[index] / totalSeconds * 100).round();
      assignedPercent += percent;
      zones.add(
        AdvancedAnalysisHeartRateZone(
          label: 'Zone ${index + 1}',
          percent: percent,
          isTarget: _isTargetZone(index),
        ),
      );
    }
    return List<AdvancedAnalysisHeartRateZone>.unmodifiable(zones);
  }

  int targetPercent(List<AdvancedAnalysisHeartRateZone> zones) {
    return zones
        .where((zone) => zone.isTarget)
        .fold<int>(0, (total, zone) => total + zone.percent);
  }

  static const _zoneCount = 5;

  int _zoneIndex(int bpm) {
    if (bpm < 120) {
      return 0;
    }
    if (bpm < 150) {
      return 1;
    }
    if (bpm < 170) {
      return 2;
    }
    if (bpm < 190) {
      return 3;
    }
    return 4;
  }

  bool _isTargetZone(int index) {
    return index == 1 || index == 2;
  }
}
