class RunLocationSample {
  const RunLocationSample({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.horizontalAccuracyMeters,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? horizontalAccuracyMeters;
}
