import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as productionFunctions from "../src/index.js";

/**
 * Every function deployed from the production entrypoint.
 *
 * This is a deliberate maintenance burden: an export added here is a publicly
 * deployed callable/trigger, so adding one must be a conscious, reviewed act
 * rather than a side effect. Adding a Function without updating this list is
 * expected to fail the suite.
 *
 * Kept in `feedCallableSurface.test.ts` for historical reasons — the Feed
 * capsule introduced the guard — but it covers the whole entrypoint, not just
 * Feed. The Feed-owned subset is asserted separately below.
 */
const expectedExports = [
  "abandonChallenge",
  "activityFeedbackAgent",
  "blockUser",
  "cancelChallengeLobby",
  "cancelFriendRequest",
  "checkNicknameAvailability",
  "cleanupDeletedFeedActivity",
  "completeCoolDown",
  "completeRun",
  "createChallengeLobby",
  "deleteFeedPost",
  "dispatchScheduledPushNotifications",
  "expireSubscriptions",
  "feedCommentCreated",
  "feedCommentDeleted",
  "feedCommentUpdated",
  "feedLikeCreated",
  "feedLikeDeleted",
  "getActiveChallenge",
  "getChallengeCatalog",
  "getChallengeInvitations",
  "homeGuideAgent",
  "homeGuideConsent",
  "inviteChallengeFriends",
  "leaderboardAdminCommandCreated",
  "leaveChallenge",
  "migrateUnicodeNicknameClaims",
  "moderationCommandCreated",
  "publishActivityToFeed",
  "readFeedThumbnail",
  "refreshLeaderboardSnapshots",
  "refreshStreakStatus",
  "registerNotificationDevice",
  "removeFriend",
  "reportAppError",
  "reportFeedPost",
  "respondToChallengeInvitation",
  "respondToFriendRequest",
  "searchFriends",
  "sendFriendRequest",
  "settleChallengeDeadlines",
  "startChallenge",
  "submitFeedback",
  "unblockUser",
  "unregisterNotificationDevice",
  "upsertNickname",
  "withdrawFromChallengeLobby",
] as const;

const feedExports = [
  "cleanupDeletedFeedActivity",
  "deleteFeedPost",
  "feedCommentCreated",
  "feedCommentDeleted",
  "feedCommentUpdated",
  "feedLikeCreated",
  "feedLikeDeleted",
  "publishActivityToFeed",
  "readFeedThumbnail",
  "reportFeedPost",
] as const;

describe("Feed callable production surface", () => {
  it("exports exactly the production Feed callables and triggers once", () => {
    assert.deepEqual(Object.keys(productionFunctions).sort(), [...expectedExports].sort());
    assert.deepEqual(
      Object.keys(productionFunctions).filter(isFeedExport).sort(),
      [...feedExports].sort(),
    );
  });

  it("does not leak Feed fixture or core helpers through the production entrypoint", () => {
    for (const name of [
      "applySyntheticFeedFixture",
      "assertFeedFixtureEnvironment",
      "createFeedEngagementHandlers",
      "createPublishPorts",
      "createThumbnailPorts",
      "publishFeedActivity",
      "readFeedThumbnailCore",
      "syntheticFeedFixture",
    ]) {
      assert.equal(name in productionFunctions, false, `${name} must not be a deployed Function export`);
    }
  });
});

function isFeedExport(name: string): name is (typeof feedExports)[number] {
  return feedExports.some((feedExport) => feedExport === name);
}
