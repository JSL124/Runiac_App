import '../services/pace_graph_data_builder.dart';
import 'cadence_analysis_series.dart';
import 'elevation_analysis_series.dart';

class LocalRunCompletionPayload {
  const LocalRunCompletionPayload({
    required this.clientRunSessionId,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.avgPaceSecondsPerKm,
    required this.source,
    required this.routePrivacy,
    this.routeLabel,
    this.clientAppVersion,
    this.paceGraphSamples = const <PaceGraphSample>[],
    this.cadenceAnalysisSeries,
    this.elevationAnalysisSeries,
  });

  final String clientRunSessionId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final int distanceMeters;
  final int avgPaceSecondsPerKm;
  final String source;
  final String routePrivacy;
  final String? routeLabel;
  final String? clientAppVersion;
  final List<PaceGraphSample> paceGraphSamples;
  final CadenceAnalysisSeries? cadenceAnalysisSeries;
  final ElevationAnalysisSeries? elevationAnalysisSeries;

  Map<String, Object?> toRawClientMap() {
    return <String, Object?>{
      'clientRunSessionId': clientRunSessionId,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'avgPaceSecondsPerKm': avgPaceSecondsPerKm,
      'source': source,
      'routePrivacy': routePrivacy,
      if (routeLabel != null) 'routeLabel': routeLabel,
      if (clientAppVersion != null) 'clientAppVersion': clientAppVersion,
    };
  }
}
