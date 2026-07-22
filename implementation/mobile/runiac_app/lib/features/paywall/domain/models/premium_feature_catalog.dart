import 'package:flutter/material.dart';

/// Runner-facing display entry for one `config/featureAccess` feature key.
@immutable
class PremiumFeatureDisplay {
  const PremiumFeatureDisplay({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Display catalog for the feature keys the admin console can premium-check,
/// mirroring the console's `FEATURE_LABELS` in
/// `website/src/components/admin/PolicySettings.tsx` (labels only — the
/// console's descriptions are admin-facing and are not shown to runners).
///
/// An unknown key (a backend catalog addition this build predates) falls
/// back to a humanized form of the key so it never renders blank.
const Map<String, PremiumFeatureDisplay> premiumFeatureCatalog = {
  'advancedAnalysis': PremiumFeatureDisplay(
    label: 'Advanced run analysis',
    icon: Icons.query_stats_rounded,
  ),
  'goalPlan': PremiumFeatureDisplay(
    label: 'Generated goal plan',
    icon: Icons.flag_rounded,
  ),
  'aiHomeCoach': PremiumFeatureDisplay(
    label: 'AI home coach',
    icon: Icons.tips_and_updates_rounded,
  ),
  'activityFeedback': PremiumFeatureDisplay(
    label: 'AI activity feedback',
    icon: Icons.auto_awesome_rounded,
  ),
  'routeLibrary': PremiumFeatureDisplay(
    label: 'Route library',
    icon: Icons.map_rounded,
  ),
  'shareRouteToFeed': PremiumFeatureDisplay(
    label: 'Share route to feed',
    icon: Icons.route_rounded,
  ),
  'shareCards': PremiumFeatureDisplay(
    label: 'Share cards',
    icon: Icons.ios_share_rounded,
  ),
  'healthWorkoutImport': PremiumFeatureDisplay(
    label: 'Health workout import',
    icon: Icons.monitor_heart_rounded,
  ),
};

PremiumFeatureDisplay premiumFeatureDisplayFor(String key) {
  final known = premiumFeatureCatalog[key];
  if (known != null) {
    return known;
  }
  return PremiumFeatureDisplay(
    label: _humanizeFeatureKey(key),
    icon: Icons.star_rounded,
  );
}

/// `healthWorkoutImport` -> `Health workout import`.
String _humanizeFeatureKey(String key) {
  final buffer = StringBuffer();
  for (var i = 0; i < key.length; i++) {
    final char = key[i];
    final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
    if (i == 0) {
      buffer.write(char.toUpperCase());
    } else if (isUpper) {
      buffer
        ..write(' ')
        ..write(char.toLowerCase());
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}
