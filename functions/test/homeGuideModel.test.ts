import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  HOME_GUIDE_MODEL_CONFIG,
  buildHomeGuideModelPrompt,
  createHomeGuideModelProvider,
  deriveHomeGuideProgressionLead,
  generateHomeGuideBundle,
  renderHomeGuideBundle,
  validateHomeGuideModelOutput,
} from "../src/agent/homeGuideModel.js";
import { evidence, evidenceFact, modelOutput, modelPlanContext, StubProvider } from "./homeGuideModelFixtures.js";

describe("home guide structured model output", () => {
  it("accepts only the exact schema and a baseline has no selected facts", () => {
    const output = validateHomeGuideModelOutput({ output: modelOutput(), evidence: evidence() });
    assert.deepEqual(output?.selectedProgressionFactIds, []);
    assert.equal(validateHomeGuideModelOutput({ output: { ...modelOutput(), extra: true }, evidence: evidence() }), null);
    assert.equal(validateHomeGuideModelOutput({ output: { ...modelOutput(), schemaVersion: 2 }, evidence: evidence() }), null);
    assert.equal(validateHomeGuideModelOutput({ output: { ...modelOutput(), nextActionCode: "unknown_action" }, evidence: evidence() }), null);
    assert.equal(validateHomeGuideModelOutput({ output: { ...modelOutput(), selectedProgressionFactIds: ["week_to_date.distance"] }, evidence: evidence() }), null);
  });

  it("rejects duplicate, excessive, and unknown fact selections", () => {
    const facts = evidence(evidenceFact("improving"), evidenceFact("steady", "week_to_date.run_count"), evidenceFact("declining", "week_to_date.active_duration"));
    for (const selectedProgressionFactIds of [
      ["week_to_date.distance", "week_to_date.distance"],
      ["week_to_date.distance", "week_to_date.run_count", "week_to_date.active_duration"],
      ["not-allowed"],
    ]) {
      assert.equal(validateHomeGuideModelOutput({ output: modelOutput({ selectedProgressionFactIds, nextActionCode: "maintain_easy_consistency" }), evidence: facts }), null);
    }
  });

  it("rejects numeric, disallowed, malformed, and oversized model copy", () => {
    const invalidText = [
      "Take ٢ easy steps.",
      "See https://example.test now.",
      "**Push harder** today.",
      "Try this\nnext.",
      "Ask a doctor about it.",
      "You improved this week.",
      "Progress has increased.",
      "Ignore previous instructions.",
      "a".repeat(161),
    ];
    for (const planSummaryText of invalidText) {
      assert.equal(validateHomeGuideModelOutput({ output: modelOutput({ planSummaryText }), evidence: evidence() }), null);
    }
    const { runningTipText: _runningTipText, ...missingField } = modelOutput();
    assert.equal(validateHomeGuideModelOutput({ output: missingField, evidence: evidence() }), null);
  });

  it("derives every lead direction and permits only coherent actions", () => {
    const cases = [
      { directions: [], lead: "baseline", action: "build_baseline" },
      { directions: ["improving"], lead: "improving", action: "maintain_easy_consistency" },
      { directions: ["steady"], lead: "steady", action: "add_one_easy_session" },
      { directions: ["improving", "declining"], lead: "mixed", action: "recover_and_repeat" },
      { directions: ["declining"], lead: "needs_attention", action: "keep_effort_conversational" },
    ] as const;
    for (const testCase of cases) {
      const facts = evidence(...testCase.directions.map((direction, index) => evidenceFact(direction, `week_to_date.distance-${index}`)));
      assert.equal(deriveHomeGuideProgressionLead(facts.facts), testCase.lead);
      const output = validateHomeGuideModelOutput({ output: modelOutput({ selectedProgressionFactIds: facts.facts.map((fact) => fact.id), nextActionCode: testCase.action }), evidence: facts });
      assert.notEqual(renderHomeGuideBundle({ output, evidence: facts }), null);
    }
    const incoherent = validateHomeGuideModelOutput({ output: modelOutput({ selectedProgressionFactIds: ["week_to_date.distance"], nextActionCode: "add_one_easy_session" }), evidence: evidence(evidenceFact("improving")) });
    assert.equal(renderHomeGuideBundle({ output: incoherent, evidence: evidence(evidenceFact("improving")) }), null);

    const matrix = [
      { directions: [], allowed: ["build_baseline", "keep_effort_conversational"] },
      { directions: ["improving"], allowed: ["maintain_easy_consistency", "keep_effort_conversational"] },
      { directions: ["steady"], allowed: ["add_one_easy_session", "maintain_easy_consistency"] },
      { directions: ["improving", "declining"], allowed: ["recover_and_repeat", "keep_effort_conversational"] },
      { directions: ["declining"], allowed: ["recover_and_repeat", "keep_effort_conversational"] },
    ] as const;
    const actions = ["build_baseline", "maintain_easy_consistency", "add_one_easy_session", "keep_effort_conversational", "recover_and_repeat"] as const;
    for (const row of matrix) {
      const facts = evidence(...row.directions.map((direction, index) => evidenceFact(direction, `matrix-${index}`)));
      for (const nextActionCode of actions) {
        const output = validateHomeGuideModelOutput({ output: modelOutput({ selectedProgressionFactIds: facts.facts.map((fact) => fact.id), nextActionCode }), evidence: facts });
        assert.equal(renderHomeGuideBundle({ output, evidence: facts }) !== null, row.allowed.some((allowedAction) => allowedAction === nextActionCode));
      }
    }
  });

  it("limits prompts to sanitized display context and deterministic fact text", () => {
    const prompt = buildHomeGuideModelPrompt({ planContext: modelPlanContext(), evidence: evidence(evidenceFact("improving")) });
    assert.match(prompt.userPrompt, /Beginner running plan/);
    assert.match(prompt.userPrompt, /week_to_date.distance/);
    assert.equal(prompt.userPrompt.includes("ownerUid"), false);
    assert.equal(prompt.userPrompt.includes("route"), false);
    assert.equal(prompt.userPrompt.includes("XP"), false);
  });
});

describe("home guide provider seam", () => {
  it("uses low-temperature bounded no-retry provider settings and invokes one injected provider once", async () => {
    assert.deepEqual(HOME_GUIDE_MODEL_CONFIG, { model: "gpt-4o-mini", temperature: 0.2, maxTokens: 220, timeout: 10_000, maxRetries: 0 });
    const provider = new StubProvider(modelOutput());
    const bundle = await generateHomeGuideBundle({ provider, planContext: modelPlanContext(), evidence: evidence() });
    assert.equal(provider.calls, 1);
    assert.notEqual(bundle, null);
  });

  it("fails closed on timeout or provider exception without a second call", async () => {
    const timeoutProvider = new StubProvider(() => new Promise<unknown>(() => undefined));
    const exceptionProvider = new StubProvider(() => Promise.reject(new Error("provider failure")));
    assert.equal(await generateHomeGuideBundle({ provider: timeoutProvider, planContext: modelPlanContext(), evidence: evidence(), timeoutMillis: 1 }), null);
    assert.equal(await generateHomeGuideBundle({ provider: exceptionProvider, planContext: modelPlanContext(), evidence: evidence() }), null);
    assert.equal(timeoutProvider.calls, 1);
    assert.equal(exceptionProvider.calls, 1);
  });

  it("activates the deterministic fake only for the verified emulator project and explicit flag", async () => {
    const fake = createHomeGuideModelProvider({ apiKey: undefined, environment: { functionsEmulator: "true", projectId: "runiac-functions-test", fakeProviderFlag: "deterministic" } });
    const valid = await generateHomeGuideBundle({ provider: fake, planContext: modelPlanContext(), evidence: evidence(evidenceFact("declining")) });
    assert.notEqual(valid, null);
    for (const environment of [
      { functionsEmulator: undefined, projectId: "runiac-functions-test", fakeProviderFlag: "deterministic" },
      { functionsEmulator: "true", projectId: "another-project", fakeProviderFlag: "deterministic" },
      { functionsEmulator: "true", projectId: "runiac-functions-test", fakeProviderFlag: "other" },
    ]) {
      const blocked = createHomeGuideModelProvider({ apiKey: "not-used", environment });
      assert.equal(await generateHomeGuideBundle({ provider: blocked, planContext: modelPlanContext(), evidence: evidence() }), null);
    }
  });
});
