import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { Timestamp } from "firebase-admin/firestore";
import { isPremiumSubscription } from "../src/progression/progressionAuditHelpers.js";

const nowMs = Date.UTC(2026, 6, 13, 10, 0, 0);
const pastMs = nowMs - 24 * 60 * 60 * 1000;
const futureMs = nowMs + 24 * 60 * 60 * 1000;

describe("isPremiumSubscription", () => {
  it("is not premium when subscriptionStatus is basic or absent", () => {
    assert.equal(isPremiumSubscription({ subscriptionStatus: "basic" }, nowMs), false);
    assert.equal(isPremiumSubscription(undefined, nowMs), false);
    assert.equal(isPremiumSubscription({}, nowMs), false);
  });

  it("stays premium forever when subscriptionExpiresAt is absent (zero regression for existing docs)", () => {
    assert.equal(isPremiumSubscription({ subscriptionStatus: "premium" }, nowMs), true);
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: null }, nowMs),
      true,
    );
  });

  it("stays premium while subscriptionExpiresAt (Timestamp) is in the future", () => {
    const data = {
      subscriptionStatus: "premium",
      subscriptionExpiresAt: Timestamp.fromMillis(futureMs),
    };
    assert.equal(isPremiumSubscription(data, nowMs), true);
  });

  it("is not premium once subscriptionExpiresAt (Timestamp) is in the past", () => {
    const data = {
      subscriptionStatus: "premium",
      subscriptionExpiresAt: Timestamp.fromMillis(pastMs),
    };
    assert.equal(isPremiumSubscription(data, nowMs), false);
  });

  it("tolerates an ISO string expiry", () => {
    assert.equal(
      isPremiumSubscription(
        { subscriptionStatus: "premium", subscriptionExpiresAt: new Date(futureMs).toISOString() },
        nowMs,
      ),
      true,
    );
    assert.equal(
      isPremiumSubscription(
        { subscriptionStatus: "premium", subscriptionExpiresAt: new Date(pastMs).toISOString() },
        nowMs,
      ),
      false,
    );
  });

  it("tolerates a millis-number expiry", () => {
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: futureMs }, nowMs),
      true,
    );
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: pastMs }, nowMs),
      false,
    );
  });

  it("treats the boundary instant (expiresAt === now) as expired", () => {
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: nowMs }, nowMs),
      false,
    );
  });

  it("treats an unparseable expiry value as no-expiry rather than throwing", () => {
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: "not-a-date" }, nowMs),
      true,
    );
    assert.equal(
      isPremiumSubscription({ subscriptionStatus: "premium", subscriptionExpiresAt: {} }, nowMs),
      true,
    );
  });

  it("accepts the legacy capitalized 'Premium' status", () => {
    assert.equal(isPremiumSubscription({ subscriptionStatus: "Premium" }, nowMs), true);
  });
});
