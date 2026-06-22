import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/cadence_analysis_derivation.dart';
import 'package:runiac_app/features/run/domain/models/cadence_analysis_series.dart';
import 'package:runiac_app/features/run/domain/services/cadence_analysis_deriver.dart';

void main() {
  group('CadenceAnalysisDeriver', () {
    const deriver = CadenceAnalysisDeriver();

    test('derives average, lowest, highest, and stable rhythm', () {
      final result = deriver.derive(
        CadenceAnalysisSeries.localAccepted(
          samples: const <CadenceAnalysisSample>[
            CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 162),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cadenceSpm: 164,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cadenceSpm: 166,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 240,
              cadenceSpm: 164,
            ),
          ],
        ),
      );

      expect(result.isAvailable, isTrue);
      expect(result.averageCadenceSpm, 164);
      expect(result.lowestCadenceSpm, 162);
      expect(result.highestCadenceSpm, 166);
      expect(result.stability, CadenceStability.stable);
      expect(result.trend, CadenceTrend.stable);
      expect(result.unavailableReason, CadenceAnalysisUnavailableReason.none);
    });

    test('derives variable rhythm when cadence spread is large', () {
      final result = deriver.derive(
        CadenceAnalysisSeries.localAccepted(
          samples: const <CadenceAnalysisSample>[
            CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 142),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cadenceSpm: 158,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cadenceSpm: 174,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 240,
              cadenceSpm: 166,
            ),
          ],
        ),
      );

      expect(result.isAvailable, isTrue);
      expect(result.stability, CadenceStability.variable);
      expect(result.highestCadenceSpm, 174);
      expect(result.lowestCadenceSpm, 142);
    });

    test('detects cadence drop and rise using first and second halves', () {
      final dropping = deriver.derive(
        CadenceAnalysisSeries.localAccepted(
          samples: const <CadenceAnalysisSample>[
            CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 172),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cadenceSpm: 170,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cadenceSpm: 158,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 240,
              cadenceSpm: 156,
            ),
          ],
        ),
      );
      final rising = deriver.derive(
        CadenceAnalysisSeries.localAccepted(
          samples: const <CadenceAnalysisSample>[
            CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 154),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cadenceSpm: 156,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 180,
              cadenceSpm: 168,
            ),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 240,
              cadenceSpm: 170,
            ),
          ],
        ),
      );

      expect(dropping.trend, CadenceTrend.dropping);
      expect(rising.trend, CadenceTrend.rising);
    });

    test('returns unavailable for insufficient samples', () {
      final result = deriver.derive(
        CadenceAnalysisSeries.localAccepted(
          samples: const <CadenceAnalysisSample>[
            CadenceAnalysisSample.accepted(elapsedSeconds: 60, cadenceSpm: 162),
            CadenceAnalysisSample.accepted(
              elapsedSeconds: 120,
              cadenceSpm: 164,
            ),
          ],
        ),
      );

      expect(result.isAvailable, isFalse);
      expect(result.averageCadenceSpm, isNull);
      expect(result.stability, CadenceStability.insufficientData);
      expect(result.trend, CadenceTrend.insufficientData);
      expect(
        result.unavailableReason,
        CadenceAnalysisUnavailableReason.insufficientSamples,
      );
    });

    test(
      'returns unavailable for static, unavailable, and non-monotonic series',
      () {
        final demo = deriver.derive(
          CadenceAnalysisSeries.staticDemo(
            samples: const <CadenceAnalysisSample>[
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 60,
                cadenceSpm: 162,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 120,
                cadenceSpm: 164,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 180,
                cadenceSpm: 166,
              ),
            ],
          ),
        );
        final unavailable = deriver.derive(CadenceAnalysisSeries.unavailable());
        final nonMonotonic = deriver.derive(
          CadenceAnalysisSeries.localAccepted(
            samples: const <CadenceAnalysisSample>[
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 60,
                cadenceSpm: 162,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 120,
                cadenceSpm: 164,
              ),
              CadenceAnalysisSample.accepted(
                elapsedSeconds: 90,
                cadenceSpm: 166,
              ),
            ],
          ),
        );

        expect(
          demo.unavailableReason,
          CadenceAnalysisUnavailableReason.staticDemoSource,
        );
        expect(
          unavailable.unavailableReason,
          CadenceAnalysisUnavailableReason.unavailableSource,
        );
        expect(
          nonMonotonic.unavailableReason,
          CadenceAnalysisUnavailableReason.nonMonotonicSeries,
        );
      },
    );

    test('derivation result constructors reject ambiguous states', () {
      expect(
        () => CadenceAnalysisDerivation.available(
          source: CadenceAnalysisSource.staticDemo,
          confidence: CadenceAnalysisConfidence.demo,
          averageCadenceSpm: 164,
          lowestCadenceSpm: 162,
          highestCadenceSpm: 166,
          stability: CadenceStability.stable,
          trend: CadenceTrend.stable,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => CadenceAnalysisDerivation.available(
          source: CadenceAnalysisSource.localAccepted,
          confidence: CadenceAnalysisConfidence.derived,
          averageCadenceSpm: 180,
          lowestCadenceSpm: 170,
          highestCadenceSpm: 176,
          stability: CadenceStability.stable,
          trend: CadenceTrend.stable,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => CadenceAnalysisDerivation.available(
          source: CadenceAnalysisSource.localAccepted,
          confidence: CadenceAnalysisConfidence.derived,
          averageCadenceSpm: 164,
          lowestCadenceSpm: 120,
          highestCadenceSpm: 180,
          stability: CadenceStability.stable,
          trend: CadenceTrend.stable,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => CadenceAnalysisDerivation.unavailable(
          reason: CadenceAnalysisUnavailableReason.staticDemoSource,
          source: CadenceAnalysisSource.localAccepted,
          confidence: CadenceAnalysisConfidence.derived,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
