import { HttpsError } from "firebase-functions/v2/https";
import type { FeatureAccessConfig } from "../../config/configLoader.js";
import { isPremiumSubscription } from "../../progression/progressionAuditHelpers.js";

// Feature key in config/featureAccess.features that governs publishing a run
// to the Feed. Mirrors DEFAULT_FEATURE_ACCESS_CONFIG in configLoader.ts.
export const SHARE_ROUTE_TO_FEED_FEATURE_KEY = "shareRouteToFeed";

// Stable, client-inspectable reason code returned in the HttpsError details so
// the app can distinguish "you need Premium" from other publish failures.
// Mirrors the activity-feedback gate's reason contract.
export const SHARE_ROUTE_TO_FEED_PREMIUM_REQUIRED_REASON = "premium-required";

/**
 * Server-side entitlement gate for publishing a run to the Feed.
 *
 * Config-driven: reads `config/featureAccess.features.shareRouteToFeed`. When
 * that feature's `minimumTier` is `"premium"`, only premium subscribers may
 * publish; when `"basic"` (or the entry is absent/disabled from the tier
 * perspective) every authenticated owner may publish, preserving the historical
 * behaviour. This is the FIRST real consumer of the feature-access config plane
 * — it makes the admin console's Share-route toggle actually enforce, rather
 * than only hiding client UI (which the PDD forbids as the sole gate).
 *
 * Pure over its inputs so it unit-tests without Firestore: the callable passes
 * the `users/{uid}` document it has already fetched for the suspension check,
 * the loaded config, and a clock reading.
 */
export function assertShareRouteToFeedEntitlement(
  userData: FirebaseFirestore.DocumentData | undefined,
  featureAccess: FeatureAccessConfig,
  nowMs: number,
): void {
  const entry = featureAccess.features[SHARE_ROUTE_TO_FEED_FEATURE_KEY];
  if (entry?.minimumTier !== "premium") {
    return;
  }
  if (isPremiumSubscription(userData, nowMs)) {
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Sharing routes to Feed is available on Premium.",
    { reason: SHARE_ROUTE_TO_FEED_PREMIUM_REQUIRED_REASON },
  );
}
