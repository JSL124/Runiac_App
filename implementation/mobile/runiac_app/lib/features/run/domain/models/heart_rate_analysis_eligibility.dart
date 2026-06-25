enum HeartRateAnalysisEligibility {
  unavailable,
  recordedOnly,
  qualityLimited,
  zoneReady;

  bool get allowsZoneAnalysis => this == HeartRateAnalysisEligibility.zoneReady;
}
