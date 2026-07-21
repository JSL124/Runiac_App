import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { getFeedAuthorLevels, type FeedAuthorLevelsPorts } from "../src/feed/authorLevels/core.js";
import type { FeedRelationshipCheckInput } from "../src/feed/relationship.js";

const viewer = "viewer-a";
const friend = "friend-a";
const stranger = "stranger-a";
const blocked = "blocked-a";

describe("Feed author levels core", () => {
  it("resolves the caller's own uid, a reciprocal friend, and omits a denied/blocked uid", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { levelLabel: "Champion", levelProgressPercent: 42 });
    ports.profiles.set(friend, { levelLabel: "Rookie", levelProgressPercent: 10 });
    ports.relationships.set(stranger, { viewerHasAuthorFriend: false, authorHasViewerFriend: false, viewerBlockedAuthor: false, authorBlockedViewer: false });
    ports.relationships.set(blocked, { viewerHasAuthorFriend: true, authorHasViewerFriend: true, viewerBlockedAuthor: true, authorBlockedViewer: false });
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer, friend, stranger, blocked] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "Champion", levelProgressPercent: 42 });
    assert.deepEqual(result.levels[friend], { levelLabel: "Rookie", levelProgressPercent: 10 });
    assert.equal(stranger in result.levels, false);
    assert.equal(blocked in result.levels, false);
  });

  it("dedupes repeated uids into a single entry and a single profile read", async () => {
    const ports = fakePorts();
    ports.profiles.set(friend, { levelLabel: "Rookie", levelProgressPercent: 10 });
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [friend, friend, friend] } }, ports);
    assert.equal(Object.keys(result.levels).length, 1);
    assert.deepEqual(result.levels[friend], { levelLabel: "Rookie", levelProgressPercent: 10 });
    assert.equal(ports.readProfilesCalls.length, 1);
    assert.equal(ports.readProfilesCalls[0]?.length, 1);
  });

  it("throws invalid-argument when more than 50 distinct uids are requested", async () => {
    const ports = fakePorts();
    const uids = Array.from({ length: 51 }, (_, index) => `uid-${index}`);
    await rejects(() => getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids } }, ports), "invalid-argument");
  });

  it("returns an empty levels map with no profile read for an empty uid array", async () => {
    const ports = fakePorts();
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [] } }, ports);
    assert.deepEqual(result.levels, {});
    assert.equal(ports.readProfilesCalls.length, 0);
  });

  it("resolves a missing profile document to an empty label and zero percent", async () => {
    const ports = fakePorts();
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "", levelProgressPercent: 0 });
  });

  it("falls back to Lv.{level} when levelLabel is absent", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { level: 7 });
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "Lv.7", levelProgressPercent: 0 });
  });

  it("clamps an out-of-range levelProgressPercent into 0..100", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { levelLabel: "Champion", levelProgressPercent: 250 });
    const overResult = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.equal(overResult.levels[viewer]?.levelProgressPercent, 100);
    ports.profiles.set(viewer, { levelLabel: "Champion", levelProgressPercent: -5 });
    const underResult = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.equal(underResult.levels[viewer]?.levelProgressPercent, 0);
  });

  it("treats a non-finite levelProgressPercent as zero", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { levelLabel: "Champion", levelProgressPercent: Number.NaN });
    const result = await getFeedAuthorLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.equal(result.levels[viewer]?.levelProgressPercent, 0);
  });

  it("rejects malformed payloads with invalid-argument", async () => {
    const ports = fakePorts();
    for (const data of [
      {}, { uids: "not-an-array" }, { uids: [123] }, { uids: [""] }, { uids: [viewer], extra: true }, { uids: [viewer, ""] },
    ]) {
      await rejects(() => getFeedAuthorLevels({ auth: { uid: viewer }, data }, ports), "invalid-argument");
    }
  });

  it("rejects an unauthenticated request with unauthenticated", async () => {
    const ports = fakePorts();
    await rejects(() => getFeedAuthorLevels({ data: { uids: [viewer] } }, ports), "unauthenticated");
  });
});

type Profile = { readonly levelLabel?: string; readonly level?: number; readonly levelProgressPercent?: number };
class FakePorts implements FeedAuthorLevelsPorts {
  profiles = new Map<string, Profile>();
  relationships = new Map<string, Partial<FeedRelationshipCheckInput>>();
  readProfilesCalls: (readonly string[])[] = [];
  async relationshipFor(viewerUid: string, authorUid: string): Promise<FeedRelationshipCheckInput> {
    const overrides = this.relationships.get(authorUid) ?? { viewerHasAuthorFriend: true, authorHasViewerFriend: true, viewerBlockedAuthor: false, authorBlockedViewer: false };
    return { viewerUid, authorUid, viewerHasAuthorFriend: true, authorHasViewerFriend: true, viewerBlockedAuthor: false, authorBlockedViewer: false, ...overrides };
  }
  async readProfiles(uids: readonly string[]): Promise<readonly (Readonly<Record<string, unknown>> | undefined)[]> {
    this.readProfilesCalls.push(uids);
    return uids.map((uid) => this.profiles.get(uid));
  }
}
function fakePorts(): FakePorts { return new FakePorts(); }
async function rejects(action: () => Promise<unknown>, code: string): Promise<void> {
  await assert.rejects(action, (error: unknown) => typeof error === "object" && error !== null && "code" in error && error["code"] === code);
}
