import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as productionFunctions from "../src/index.js";

const expectedExports = [
  "cleanupDeletedFeedActivity",
  "completeRun",
  "deleteFeedPost",
  "dispatchScheduledPushNotifications",
  "feedCommentCreated",
  "feedCommentDeleted",
  "feedCommentUpdated",
  "feedLikeCreated",
  "feedLikeDeleted",
  "homeGuideAgent",
  "publishActivityToFeed",
  "readFeedThumbnail",
  "refreshLeaderboardSnapshots",
  "refreshStreakStatus",
  "registerNotificationDevice",
  "reportFeedPost",
  "unregisterNotificationDevice",
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
