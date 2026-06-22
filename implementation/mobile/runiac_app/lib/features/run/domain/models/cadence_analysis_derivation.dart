import 'cadence_analysis_series.dart';

const stableCadenceSpreadSpm = 8;
const cadenceTrendDeltaSpm = 8;

enum CadenceStability { stable, variable, insufficientData, unavailable }

enum CadenceTrend { stable, dropping, rising, insufficientData, unavailable }

enum CadenceAnalysisUnavailableReason {
  none,
  staticDemoSource,
  unavailableSource,
  invalidSource,
  insufficientSamples,
  nonMonotonicSeries,
}

class CadenceAnalysisDerivation {
  const CadenceAnalysisDerivation._({
    required this.source,
    required this.confidence,
    required this.averageCadenceSpm,
    required this.lowestCadenceSpm,
    required this.highestCadenceSpm,
    required this.stability,
    required this.trend,
    required this.unavailableReason,
  });

  factory CadenceAnalysisDerivation.available({
    required CadenceAnalysisSource source,
    required CadenceAnalysisConfidence confidence,
    required int averageCadenceSpm,
    required int lowestCadenceSpm,
    required int highestCadenceSpm,
    required CadenceStability stability,
    required CadenceTrend trend,
  }) {
    _validateAvailableState(
      source: source,
      confidence: confidence,
      averageCadenceSpm: averageCadenceSpm,
      lowestCadenceSpm: lowestCadenceSpm,
      highestCadenceSpm: highestCadenceSpm,
      stability: stability,
      trend: trend,
    );
    return CadenceAnalysisDerivation._(
      source: source,
      confidence: confidence,
      averageCadenceSpm: averageCadenceSpm,
      lowestCadenceSpm: lowestCadenceSpm,
      highestCadenceSpm: highestCadenceSpm,
      stability: stability,
      trend: trend,
      unavailableReason: CadenceAnalysisUnavailableReason.none,
    );
  }

  factory CadenceAnalysisDerivation.unavailable({
    required CadenceAnalysisUnavailableReason reason,
    CadenceAnalysisSource source = CadenceAnalysisSource.unavailableUnknown,
    CadenceAnalysisConfidence confidence =
        CadenceAnalysisConfidence.unavailable,
  }) {
    _validateUnavailableState(
      reason: reason,
      source: source,
      confidence: confidence,
    );
    return CadenceAnalysisDerivation._(
      source: source,
      confidence: confidence,
      averageCadenceSpm: null,
      lowestCadenceSpm: null,
      highestCadenceSpm: null,
      stability: reason == CadenceAnalysisUnavailableReason.insufficientSamples
          ? CadenceStability.insufficientData
          : CadenceStability.unavailable,
      trend: reason == CadenceAnalysisUnavailableReason.insufficientSamples
          ? CadenceTrend.insufficientData
          : CadenceTrend.unavailable,
      unavailableReason: reason,
    );
  }

  final CadenceAnalysisSource source;
  final CadenceAnalysisConfidence confidence;
  final int? averageCadenceSpm;
  final int? lowestCadenceSpm;
  final int? highestCadenceSpm;
  final CadenceStability stability;
  final CadenceTrend trend;
  final CadenceAnalysisUnavailableReason unavailableReason;

  bool get isAvailable {
    return unavailableReason == CadenceAnalysisUnavailableReason.none;
  }

  static void _validateAvailableState({
    required CadenceAnalysisSource source,
    required CadenceAnalysisConfidence confidence,
    required int averageCadenceSpm,
    required int lowestCadenceSpm,
    required int highestCadenceSpm,
    required CadenceStability stability,
    required CadenceTrend trend,
  }) {
    if (source != CadenceAnalysisSource.localAccepted ||
        confidence != CadenceAnalysisConfidence.derived) {
      throw ArgumentError.value(
        '$source/$confidence',
        'source/confidence',
        'available cadence analysis derivations must be local accepted and derived',
      );
    }
    if (stability == CadenceStability.insufficientData ||
        stability == CadenceStability.unavailable) {
      throw ArgumentError.value(
        stability,
        'stability',
        'available cadence analysis derivations require a stability value',
      );
    }
    if (trend == CadenceTrend.insufficientData ||
        trend == CadenceTrend.unavailable) {
      throw ArgumentError.value(
        trend,
        'trend',
        'available cadence analysis derivations require a trend value',
      );
    }
    if (!_isCadenceValueInRange(averageCadenceSpm) ||
        !_isCadenceValueInRange(lowestCadenceSpm) ||
        !_isCadenceValueInRange(highestCadenceSpm)) {
      throw ArgumentError.value(
        '$lowestCadenceSpm/$averageCadenceSpm/$highestCadenceSpm',
        'cadenceSpm',
        'available cadence analysis values must be within cadence range',
      );
    }
    if (lowestCadenceSpm > averageCadenceSpm ||
        averageCadenceSpm > highestCadenceSpm) {
      throw ArgumentError.value(
        '$lowestCadenceSpm/$averageCadenceSpm/$highestCadenceSpm',
        'cadenceSpm',
        'average cadence must be between lowest and highest cadence',
      );
    }
    final expectedStability =
        highestCadenceSpm - lowestCadenceSpm <= stableCadenceSpreadSpm
        ? CadenceStability.stable
        : CadenceStability.variable;
    if (stability != expectedStability) {
      throw ArgumentError.value(
        stability,
        'stability',
        'stability must match the cadence spread',
      );
    }
  }

  static void _validateUnavailableState({
    required CadenceAnalysisUnavailableReason reason,
    required CadenceAnalysisSource source,
    required CadenceAnalysisConfidence confidence,
  }) {
    if (reason == CadenceAnalysisUnavailableReason.none) {
      throw ArgumentError.value(
        reason,
        'reason',
        'must explain why the cadence analysis derivation is unavailable',
      );
    }
    if (!_isUnavailableSourceConsistent(reason, source, confidence)) {
      throw ArgumentError.value(
        '$reason/$source/$confidence',
        'reason/source/confidence',
        'unavailable cadence analysis source must match its reason',
      );
    }
  }

  static bool _isCadenceValueInRange(int value) {
    return value >= minCadenceAnalysisSpm && value <= maxCadenceAnalysisSpm;
  }

  static bool _isUnavailableSourceConsistent(
    CadenceAnalysisUnavailableReason reason,
    CadenceAnalysisSource source,
    CadenceAnalysisConfidence confidence,
  ) {
    return switch (reason) {
      CadenceAnalysisUnavailableReason.none => false,
      CadenceAnalysisUnavailableReason.staticDemoSource =>
        source == CadenceAnalysisSource.staticDemo &&
            confidence == CadenceAnalysisConfidence.demo,
      CadenceAnalysisUnavailableReason.unavailableSource =>
        source == CadenceAnalysisSource.unavailableUnknown &&
            confidence == CadenceAnalysisConfidence.unavailable,
      CadenceAnalysisUnavailableReason.insufficientSamples ||
      CadenceAnalysisUnavailableReason.nonMonotonicSeries =>
        source == CadenceAnalysisSource.localAccepted &&
            confidence == CadenceAnalysisConfidence.derived,
      CadenceAnalysisUnavailableReason.invalidSource =>
        !_isCanonicalStaticDemoSource(source, confidence) &&
            !_isCanonicalUnavailableSource(source, confidence) &&
            (source != CadenceAnalysisSource.localAccepted ||
                confidence != CadenceAnalysisConfidence.derived),
    };
  }

  static bool _isCanonicalStaticDemoSource(
    CadenceAnalysisSource source,
    CadenceAnalysisConfidence confidence,
  ) {
    return source == CadenceAnalysisSource.staticDemo &&
        confidence == CadenceAnalysisConfidence.demo;
  }

  static bool _isCanonicalUnavailableSource(
    CadenceAnalysisSource source,
    CadenceAnalysisConfidence confidence,
  ) {
    return source == CadenceAnalysisSource.unavailableUnknown &&
        confidence == CadenceAnalysisConfidence.unavailable;
  }
}
