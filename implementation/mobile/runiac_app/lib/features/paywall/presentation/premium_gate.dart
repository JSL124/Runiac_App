import 'package:flutter/widgets.dart';

import '../../profile/presentation/current_session_user_account.dart';
import 'current_session_paywall_config.dart';
import 'premium_paywall_sheet.dart';

/// Whether the current runner should see the paywall instead of a premium
/// feature.
///
/// Fail-open by design: an absent scope or an unresolved account
/// (`account == null` while the first snapshot loads) proceeds to the
/// feature — server rules and Cloud Functions are the real enforcement, and
/// failing closed would flash the paywall at premium runners during load.
/// The `config/paywall` `enabled` flag is a kill switch that disables the
/// UX gate entirely.
bool shouldShowPaywall(BuildContext context) {
  final account = CurrentSessionUserAccountScope.maybeRead(context)?.account;
  if (account == null || account.isPremium) {
    return false;
  }
  final config = PaywallConfigScope.maybeRead(context)?.config;
  return config == null || config.enabled;
}

/// [shouldShowPaywall] for use inside `build`: registers scope dependencies
/// so locked UI (e.g. a blurred premium card) rebuilds when the trusted
/// account state resolves or an admin flips the paywall kill switch.
bool watchShouldShowPaywall(BuildContext context) {
  final account = CurrentSessionUserAccountScope.maybeOf(context)?.account;
  if (account == null || account.isPremium) {
    return false;
  }
  final config = PaywallConfigScope.maybeOf(context)?.config;
  return config == null || config.enabled;
}

/// Intercepts a premium-feature tap for Basic runners.
///
/// Returns true when the paywall was shown (tap consumed); false when the
/// caller should proceed to the real feature.
bool interceptWithPaywallIfBasic(BuildContext context) {
  if (!shouldShowPaywall(context)) {
    return false;
  }
  PremiumPaywallSheet.show(context);
  return true;
}
