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
      // Mirrors functions DEFAULT_FEATURE_ACCESS_CONFIG, so an unreachable
      // document gates exactly like a freshly provisioned environment.
      expect(FeatureAccessReadModel.defaults.premiumFeatureKeys, const [
        'advancedAnalysis',
        'activityFeedback',
        'shareRouteToFeed',
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

    test('malformed features map falls back to defaults', () {
      expect(
        FeatureAccessReadModel.fromMap(const {'features': 'nope'}),
        FeatureAccessReadModel.defaults,
      );
    });

    test('an all-basic catalog is honoured, not read as never-configured', () {
      // Collapsing this into the defaults used to resurrect advancedAnalysis
      // as premium — which now would keep enforcing a lock the admin had
      // deliberately cleared.
      final model = FeatureAccessReadModel.fromMap(const {
        'features': {
          'advancedAnalysis': {'minimumTier': 'basic', 'enabled': true},
          'shareRouteToFeed': {'minimumTier': 'basic', 'enabled': true},
        },
      });

      expect(model.premiumFeatureKeys, isEmpty);
      expect(model.isPremiumFeature('advancedAnalysis'), isFalse);
      expect(model.isPremiumFeature('shareRouteToFeed'), isFalse);
    });

    test('entries that cannot be parsed are skipped, not fatal', () {
      final model = FeatureAccessReadModel.fromMap(const {
        'features': {
          'broken': 'not-a-map',
          '': {'minimumTier': 'premium'},
          'shareCards': {'minimumTier': 'premium', 'enabled': true},
        },
      });

      expect(model.premiumFeatureKeys, const ['shareCards']);
    });
  });

  group('FeatureAccessReadModel.isPremiumFeature', () {
    test('reports the admin-published tier for a known key', () {
      final model = FeatureAccessReadModel.fromMap(const {
        'features': {
          'shareRouteToFeed': {'minimumTier': 'premium', 'enabled': true},
          'shareCards': {'minimumTier': 'basic', 'enabled': true},
        },
      });

      expect(model.isPremiumFeature('shareRouteToFeed'), isTrue);
      expect(model.isPremiumFeature('shareCards'), isFalse);
    });

    test('an unknown key reads as basic', () {
      expect(
        FeatureAccessReadModel.defaults.isPremiumFeature('featureFromTheFuture'),
        isFalse,
      );
    });

    test('a disabled premium entry reads as basic', () {
      // Matches the backend's isPremiumGatedFeature: `enabled` means "this
      // tier rule is active", so clearing it releases the gate on both sides.
      final model = FeatureAccessReadModel.fromMap(const {
        'features': {
          'shareCards': {'minimumTier': 'premium', 'enabled': false},
        },
      });

      expect(model.isPremiumFeature('shareCards'), isFalse);
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
