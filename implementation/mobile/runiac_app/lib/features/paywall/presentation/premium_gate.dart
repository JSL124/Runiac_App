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

/// Whether a premium-only feature that has NO server-side backstop must stay
/// gated for the current runner.
///
/// Unlike [shouldShowPaywall], this fails CLOSED while the account is
/// unresolved (`account == null` during the first `users/{uid}` read): it
/// gates unless the runner is *confirmed* Premium (or the paywall kill switch
/// is off). Use for client-only gates — e.g. the cosmetic guide-character
/// picker — where the selection is persisted locally and never re-checked
/// server-side, so a tap that slipped through the load window would let a Basic
/// runner keep a premium-only choice with nothing to reject it later.
bool shouldHardGatePremium(BuildContext context) {
  final account = CurrentSessionUserAccountScope.maybeRead(context)?.account;
  if (account?.isPremium ?? false) {
    return false;
  }
  final config = PaywallConfigScope.maybeRead(context)?.config;
  return config == null || config.enabled;
}

/// [shouldHardGatePremium] for use inside `build`: registers scope
/// dependencies so the lock UI resolves the moment the trusted account (or an
/// admin kill-switch flip) arrives.
bool watchShouldHardGatePremium(BuildContext context) {
  final account = CurrentSessionUserAccountScope.maybeOf(context)?.account;
  if (account?.isPremium ?? false) {
    return false;
  }
  final config = PaywallConfigScope.maybeOf(context)?.config;
  return config == null || config.enabled;
}

/// Intercepts a tap on a client-only premium feature (see
/// [shouldHardGatePremium]). Returns true when the paywall was shown (tap
/// consumed); false when the caller should proceed to the real feature.
bool interceptWithPaywallIfHardGated(BuildContext context) {
  if (!shouldHardGatePremium(context)) {
    return false;
  }
  PremiumPaywallSheet.show(context);
  return true;
}
