import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/paywall/domain/models/feature_access_read_model.dart';
import 'package:runiac_app/features/paywall/domain/models/premium_feature_catalog.dart';

void main() {
  group('FeatureAccessReadModel.fromMap', () {
    test('missing document resolves to defaults', () {
      expect(
        FeatureAccessReadModel.fromMap(null),
        FeatureAccessReadModel.defaults,
      );
      expect(FeatureAccessReadModel.defaults.premiumFeatureKeys, const [
        'advancedAnalysis',
      ]);
    });

    test('collects only enabled premium-tier features in document order', () {
      final model = FeatureAccessReadModel.fromMap(const {
        'features': {
          'advancedAnalysis': {'minimumTier': 'premium', 'enabled': true},
          'goalPlan': {'minimumTier': 'basic', 'enabled': true},
          'shareCards': {'minimumTier': 'premium', 'enabled': false},
          'activityFeedback': {'minimumTier': 'premium'},
        },
      });

      expect(model.premiumFeatureKeys, const [
        'advancedAnalysis',
        'activityFeedback',
      ]);
    });

    test('malformed features map or zero premium entries fall back', () {
      expect(
        FeatureAccessReadModel.fromMap(const {'features': 'nope'}),
        FeatureAccessReadModel.defaults,
      );
      expect(
        FeatureAccessReadModel.fromMap(const {
          'features': {
            'goalPlan': {'minimumTier': 'basic'},
          },
        }),
        FeatureAccessReadModel.defaults,
      );
      expect(
        FeatureAccessReadModel.fromMap(const {
          'features': {
            'broken': 'not-a-map',
            '': {'minimumTier': 'premium'},
          },
        }),
        FeatureAccessReadModel.defaults,
      );
    });
  });

  group('premiumFeatureDisplayFor', () {
    test('known keys use the admin catalog labels', () {
      expect(
        premiumFeatureDisplayFor('advancedAnalysis').label,
        'Advanced run analysis',
      );
      expect(
        premiumFeatureDisplayFor('healthWorkoutImport').label,
        'Health workout import',
      );
    });

    test('unknown keys humanize instead of rendering blank', () {
      expect(
        premiumFeatureDisplayFor('someFutureFeature').label,
        'Some future feature',
      );
    });
  });
}
