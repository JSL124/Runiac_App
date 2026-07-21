import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { getFriendLevels, type FriendLevelsPorts } from "../src/friends/friendLevels/core.js";

const viewer = "viewer-a";
const friend = "friend-a";
const requested = "requested-a";
const blocked = "blocked-a";
const stranger = "stranger-a";

describe("Friend levels core", () => {
  it("resolves the caller's own uid always, without any edge lookup", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { levelLabel: "Champion", levelProgressPercent: 42 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "Champion", levelProgressPercent: 42 });
    assert.equal(ports.edgeCalls.length, 0);
  });

  it("permits a uid with a friends edge", async () => {
    const ports = fakePorts();
    ports.friendEdges.add(friend);
    ports.profiles.set(friend, { levelLabel: "Rookie", levelProgressPercent: 10 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [friend] } }, ports);
    assert.deepEqual(result.levels[friend], { levelLabel: "Rookie", levelProgressPercent: 10 });
  });

  it("permits a uid with a friendRequests edge", async () => {
    const ports = fakePorts();
    ports.requestEdges.add(requested);
    ports.profiles.set(requested, { levelLabel: "Rookie", levelProgressPercent: 5 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [requested] } }, ports);
    assert.deepEqual(result.levels[requested], { levelLabel: "Rookie", levelProgressPercent: 5 });
  });

  it("permits a uid with a blockedUsers edge", async () => {
    const ports = fakePorts();
    ports.blockEdges.add(blocked);
    ports.profiles.set(blocked, { levelLabel: "Champion", levelProgressPercent: 99 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [blocked] } }, ports);
    assert.deepEqual(result.levels[blocked], { levelLabel: "Champion", levelProgressPercent: 99 });
  });

  it("omits a uid with no edge at all", async () => {
    const ports = fakePorts();
    ports.profiles.set(stranger, { levelLabel: "Champion", levelProgressPercent: 99 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [stranger] } }, ports);
    assert.equal(stranger in result.levels, false);
  });

  it("dedupes repeated uids into a single entry and a single profile read", async () => {
    const ports = fakePorts();
    ports.friendEdges.add(friend);
    ports.profiles.set(friend, { levelLabel: "Rookie", levelProgressPercent: 10 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [friend, friend, friend] } }, ports);
    assert.equal(Object.keys(result.levels).length, 1);
    assert.deepEqual(result.levels[friend], { levelLabel: "Rookie", levelProgressPercent: 10 });
    assert.equal(ports.readProfilesCalls.length, 1);
    assert.equal(ports.readProfilesCalls[0]?.length, 1);
  });

  it("throws invalid-argument when more than 50 distinct uids are requested", async () => {
    const ports = fakePorts();
    const uids = Array.from({ length: 51 }, (_, index) => `uid-${index}`);
    await rejects(() => getFriendLevels({ auth: { uid: viewer }, data: { uids } }, ports), "invalid-argument");
  });

  it("returns an empty levels map with no profile read for an empty uid array", async () => {
    const ports = fakePorts();
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [] } }, ports);
    assert.deepEqual(result.levels, {});
    assert.equal(ports.readProfilesCalls.length, 0);
  });

  it("rejects malformed payloads with invalid-argument", async () => {
    const ports = fakePorts();
    for (const data of [
      {}, { uids: "not-an-array" }, { uids: [123] }, { uids: [""] }, { uids: [viewer], extra: true }, { uids: [viewer, ""] },
    ]) {
      await rejects(() => getFriendLevels({ auth: { uid: viewer }, data }, ports), "invalid-argument");
    }
  });

  it("rejects an unauthenticated request with unauthenticated", async () => {
    const ports = fakePorts();
    await rejects(() => getFriendLevels({ data: { uids: [viewer] } }, ports), "unauthenticated");
  });

  it("resolves a missing profile document to an empty label and zero percent", async () => {
    const ports = fakePorts();
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "", levelProgressPercent: 0 });
  });

  it("falls back to Lv.{level} when levelLabel is absent", async () => {
    const ports = fakePorts();
    ports.profiles.set(viewer, { level: 7 });
    const result = await getFriendLevels({ auth: { uid: viewer }, data: { uids: [viewer] } }, ports);
    assert.deepEqual(result.levels[viewer], { levelLabel: "Lv.7", levelProgressPercent: 0 });
  });
});

type Profile = { readonly levelLabel?: string; readonly level?: number; readonly levelProgressPercent?: number };
class FakePorts implements FriendLevelsPorts {
  profiles = new Map<string, Profile>();
  friendEdges = new Set<string>();
  requestEdges = new Set<string>();
  blockEdges = new Set<string>();
  edgeCalls: (readonly [string, string])[] = [];
  readProfilesCalls: (readonly string[])[] = [];
  async hasSocialEdge(callerUid: string, uid: string): Promise<boolean> {
    this.edgeCalls.push([callerUid, uid]);
    return this.friendEdges.has(uid) || this.requestEdges.has(uid) || this.blockEdges.has(uid);
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
