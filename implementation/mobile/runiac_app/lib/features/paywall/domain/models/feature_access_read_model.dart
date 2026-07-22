// Display-only view of the backend-owned `config/featureAccess` document:
// which feature keys the Platform Administrator has checked as
// premium-tier. The upsell section lists these; real access enforcement
// stays server-side (Cloud Functions and Firestore Rules) — the client only
// relays which features are premium for display.

import 'package:flutter/foundation.dart';

/// Premium-checked feature keys from `config/featureAccess`, in the
/// document's iteration order.
@immutable
class FeatureAccessReadModel {
  const FeatureAccessReadModel({this.premiumFeatureKeys = _defaultKeys});

  static const defaults = FeatureAccessReadModel();

  /// The one key that is premium in every environment's shipped defaults
  /// (functions `DEFAULT_FEATURE_ACCESS_CONFIG` and the admin console's
  /// mirror both start with `advancedAnalysis: premium`).
  static const _defaultKeys = <String>['advancedAnalysis'];

  /// Feature keys whose stored entry is `minimumTier == 'premium'` and
  /// `enabled == true` (absent `enabled` counts as enabled, matching the
  /// backend loader's defaults-merge).
  final List<String> premiumFeatureKeys;

  /// Maps the trusted raw document. A missing document, a malformed
  /// `features` map, or zero premium entries all resolve to [defaults] so
  /// the upsell never renders an empty list.
  factory FeatureAccessReadModel.fromMap(Map<String, Object?>? data) {
    final features = data?['features'];
    if (features is! Map) {
      return defaults;
    }
    final keys = <String>[];
    for (final entry in features.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || key.trim().isEmpty || value is! Map) {
        continue;
      }
      if (value['minimumTier'] != 'premium') {
        continue;
      }
      final enabled = value['enabled'];
      if (enabled is bool && !enabled) {
        continue;
      }
      keys.add(key.trim());
    }
    return keys.isEmpty
        ? defaults
        : FeatureAccessReadModel(premiumFeatureKeys: List.unmodifiable(keys));
  }

  @override
  bool operator ==(Object other) {
    return other is FeatureAccessReadModel &&
        listEquals(other.premiumFeatureKeys, premiumFeatureKeys);
  }

  @override
  int get hashCode => Object.hashAll(premiumFeatureKeys);
}
