import '../services/pace_graph_data_builder.dart';

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
