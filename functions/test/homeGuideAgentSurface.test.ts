import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  buildHomeGuideGraphInput,
  clampAgentMessage,
  HOME_GUIDE_SYSTEM_PROMPT,
  parseHomeGuideAgentPayload,
} from "../src/agent/homeGuideAgent.js";

describe("homeGuideAgent payload validation", () => {
  it("accepts a well-formed display-only workout payload", () => {
    const payload = parseHomeGuideAgentPayload(validPayload());

    assert.equal(payload.planTitle, "Beginner 5K Launch");
    assert.equal(payload.weekNumber, 2);
    assert.equal(payload.steps.length, 3);
  });

  it("rejects a non-object payload", () => {
    assert.throws(() => parseHomeGuideAgentPayload("not-an-object"), /Payload must be an object/);
    assert.throws(() => parseHomeGuideAgentPayload(null), /Payload must be an object/);
  });

  it("rejects unsupported fields, including backend-owned values", () => {
    const withProtectedField = { ...validPayload(), xp: 999 };
    assert.throws(() => parseHomeGuideAgentPayload(withProtectedField), /Unsupported field is not accepted: xp/);
  });

  it("rejects an empty planTitle", () => {
    const badPayload = { ...validPayload(), planTitle: "" };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /planTitle must be a non-empty string/);
  });

  it("rejects a non-integer weekNumber", () => {
    const badPayload = { ...validPayload(), weekNumber: 2.5 };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /weekNumber must be a positive integer/);
  });

  it("rejects a non-positive durationMinutes", () => {
    const badPayload = { ...validPayload(), durationMinutes: 0 };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /durationMinutes must be a positive integer/);
  });

  it("rejects steps that are not strings", () => {
    const badPayload = { ...validPayload(), steps: ["Warm up", 42] };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /steps\[1\] must be a non-empty string/);
  });

  it("rejects an overlong description", () => {
    const badPayload = { ...validPayload(), description: "x".repeat(900) };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /description must be at most/);
  });

  it("rejects too many steps", () => {
    const badPayload = { ...validPayload(), steps: Array.from({ length: 13 }, (_, i) => `Step ${i}`) };
    assert.throws(() => parseHomeGuideAgentPayload(badPayload), /steps must contain at most/);
  });
});

describe("homeGuideAgent prompt assembly", () => {
  it("builds a stable system prompt that forbids backend-owned numbers and medical claims", () => {
    assert.match(HOME_GUIDE_SYSTEM_PROMPT, /running guide agent/);
    assert.match(HOME_GUIDE_SYSTEM_PROMPT, /Never invent or state XP, level, rank, streak, or leaderboard/);
    assert.match(HOME_GUIDE_SYSTEM_PROMPT, /Never make medical claims/);
  });

  it("assembles a user prompt containing only the supplied display copy", () => {
    const payload = parseHomeGuideAgentPayload(validPayload());
    const { systemPrompt, userPrompt } = buildHomeGuideGraphInput(payload);

    assert.equal(systemPrompt, HOME_GUIDE_SYSTEM_PROMPT);
    assert.match(userPrompt, /Beginner 5K Launch/);
    assert.match(userPrompt, /Week 2 focus: Build endurance/);
    assert.match(userPrompt, /Easy Run \(25 minutes, easy intensity\)/);
    assert.match(userPrompt, /1\. Warm up with a brisk walk/);
    assert.match(userPrompt, /You've got this/);
  });

  it("falls back to a placeholder when no steps are provided", () => {
    const payload = parseHomeGuideAgentPayload({ ...validPayload(), steps: [] });
    const { userPrompt } = buildHomeGuideGraphInput(payload);

    assert.match(userPrompt, /\(no step breakdown provided\)/);
  });
});

describe("homeGuideAgent message clamping", () => {
  it("returns short messages untouched", () => {
    assert.equal(clampAgentMessage("  Great job today!  "), "Great job today!");
  });

  it("clamps overlong messages to a sane display length", () => {
    const longMessage = `${"word ".repeat(200)}done`;
    const clamped = clampAgentMessage(longMessage);

    assert.ok(clamped.length <= 604);
    assert.ok(clamped.endsWith("..."));
  });
});

function validPayload(): Record<string, unknown> {
  return {
    planTitle: "Beginner 5K Launch",
    weekNumber: 2,
    weekFocus: "Build endurance",
    dayLabel: "Wednesday",
    workoutTitle: "Easy Run",
    durationMinutes: 25,
    intensity: "easy",
    description: "A relaxed run to build your aerobic base.",
    steps: ["Warm up with a brisk walk", "Run at a conversational pace", "Cool down and stretch"],
    supportiveNote: "You've got this, one step at a time.",
  };
}
