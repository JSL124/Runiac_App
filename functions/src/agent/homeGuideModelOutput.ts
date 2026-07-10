import type { HomeGuideEvidence, HomeGuideEvidenceFact } from "./homeGuideContracts.js";
import type { HomeGuideBundle } from "./homeGuideQuotaCache.js";

const ACTION_CODES = [
  "build_baseline",
  "maintain_easy_consistency",
  "add_one_easy_session",
  "keep_effort_conversational",
  "recover_and_repeat",
] as const;
const OUTPUT_FIELDS = new Set([
  "schemaVersion",
  "planSummaryText",
  "runningTipText",
  "selectedProgressionFactIds",
  "nextActionCode",
]);
const MEDICAL_TERMS = /\b(?:diagnos(?:is|e)|doctor|medication|injury|injured|treatment|medical|pain)\b/iu;
const COMPETITIVE_TERMS = /\b(?:leaderboard|rank|ranking|win|winner|beat|competition|competitive|race)\b/iu;
const UNSUPPLIED_CLAIM = /\b(?:you|your|improv(?:e|ed|ing|ement)?|declin(?:e|ed|ing)?|increas(?:e|ed|ing)?|decreas(?:e|ed|ing)?|progress|faster|slower|distance|run count)\b/iu;
const INSTRUCTIONAL_TERMS = /\b(?:ignore|disregard|previous instructions?|system prompt)\b/iu;
const MARKDOWN = /(?:^|\s)(?:#{1,6}\s|[-*+]\s|>\s)|[*_`~\[\]]/u;
const URL = /(?:https?:\/\/|www\.)/iu;
const MAX_MODEL_TEXT_LENGTH = 128;

export type HomeGuideActionCode = (typeof ACTION_CODES)[number];
export type HomeGuideProgressionLead = "baseline" | "improving" | "steady" | "mixed" | "needs_attention";
export type HomeGuideModelOutput = {
  readonly schemaVersion: 1;
  readonly planSummaryText: string;
  readonly runningTipText: string;
  readonly selectedProgressionFactIds: readonly string[];
  readonly nextActionCode: HomeGuideActionCode;
};
export type HomeGuideModelValidationInput = {
  readonly output: unknown;
  readonly evidence: HomeGuideEvidence;
};
export type HomeGuideRenderInput = {
  readonly output: HomeGuideModelOutput | null;
  readonly evidence: HomeGuideEvidence;
};

class HomeGuideUnreachableVariantError extends Error {
  public constructor() {
    super("Home guide encountered an unhandled variant.");
    this.name = "HomeGuideUnreachableVariantError";
  }
}

export function assertNever(value: never): never {
  void value;
  throw new HomeGuideUnreachableVariantError();
}

export function validateHomeGuideModelOutput(input: HomeGuideModelValidationInput): HomeGuideModelOutput | null {
  if (!isRecord(input.output) || !hasExactKeys(input.output, OUTPUT_FIELDS)) return null;
  const schemaVersion = input.output["schemaVersion"];
  const planSummaryText = input.output["planSummaryText"];
  const runningTipText = input.output["runningTipText"];
  const selectedProgressionFactIds = input.output["selectedProgressionFactIds"];
  const nextActionCode = input.output["nextActionCode"];
  if (
    schemaVersion !== 1 ||
    !isSafeModelText(planSummaryText) ||
    !isSafeModelText(runningTipText) ||
    !isActionCode(nextActionCode) ||
    !isSelectedFactIds(selectedProgressionFactIds, input.evidence)
  ) return null;
  return { schemaVersion, planSummaryText, runningTipText, selectedProgressionFactIds, nextActionCode };
}

export function deriveHomeGuideProgressionLead(facts: readonly HomeGuideEvidenceFact[]): HomeGuideProgressionLead {
  if (facts.length === 0) return "baseline";
  const hasImproving = facts.some((fact) => fact.direction === "improving");
  const hasDeclining = facts.some((fact) => fact.direction === "declining");
  if (hasImproving && hasDeclining) return "mixed";
  if (hasImproving) return "improving";
  if (hasDeclining) return "needs_attention";
  return "steady";
}

export function renderHomeGuideBundle(input: HomeGuideRenderInput): HomeGuideBundle | null {
  if (input.output === null) return null;
  const facts = selectedFacts(input.output.selectedProgressionFactIds, input.evidence.facts);
  const lead = deriveHomeGuideProgressionLead(facts);
  if (!isCoherentAction(lead, input.output.nextActionCode)) return null;
  const bundle = {
    planSummary: `Your plan is ready, superstar! ${input.output.planSummaryText}`,
    runningTip: `Tiny trainer tip: ${input.output.runningTipText}`,
    progressionCheckIn: renderProgression(facts, input.output.nextActionCode),
  };
  return Object.values(bundle).every(isSafeFinalMessage) ? bundle : null;
}

function renderProgression(
  facts: readonly HomeGuideEvidenceFact[],
  action: HomeGuideActionCode,
): string {
  const actionText = actionSentence(action);
  if (facts.length === 0) return `You are building a running baseline. ${actionText}`;
  const detail = facts.map((fact) => fact.text.replace(/[.!?]+$/u, "")).join("; ");
  return `${detail}. ${actionText}`;
}

function actionSentence(action: HomeGuideActionCode): string {
  switch (action) {
    case "build_baseline": return "You've got this; one comfy session at a time is plenty.";
    case "maintain_easy_consistency": return "You've got this; keep your easy sessions gentle and steady.";
    case "add_one_easy_session": return "You've got this; add one easy session only when you feel ready.";
    case "keep_effort_conversational": return "You've got this; keep the effort conversational and enjoy the rhythm.";
    case "recover_and_repeat": return "You've got this; rest kindly, then repeat an easy session when ready.";
    default: return assertNever(action);
  }
}

function selectedFacts(ids: readonly string[], facts: readonly HomeGuideEvidenceFact[]): readonly HomeGuideEvidenceFact[] {
  return ids.flatMap((id) => facts.filter((fact) => fact.id === id));
}

function isCoherentAction(lead: HomeGuideProgressionLead, action: HomeGuideActionCode): boolean {
  switch (lead) {
    case "baseline": return action === "build_baseline" || action === "keep_effort_conversational";
    case "improving": return action === "maintain_easy_consistency" || action === "keep_effort_conversational";
    case "steady": return action === "add_one_easy_session" || action === "maintain_easy_consistency";
    case "mixed":
    case "needs_attention": return action === "recover_and_repeat" || action === "keep_effort_conversational";
    default: return assertNever(lead);
  }
}

function isSelectedFactIds(value: unknown, evidence: HomeGuideEvidence): value is readonly string[] {
  if (!Array.isArray(value) || value.length > 2 || !value.every((id) => typeof id === "string")) return false;
  if (new Set(value).size !== value.length) return false;
  const allowedIds = new Set(evidence.facts.map((fact) => fact.id));
  return value.every((id) => allowedIds.has(id));
}

function isSafeModelText(value: unknown): value is string {
  return typeof value === "string" &&
    value.trim().length > 0 &&
    codePointLength(value) <= MAX_MODEL_TEXT_LENGTH &&
    sentenceCount(value) <= 2 &&
    !/[\r\n%\p{N}]/u.test(value) &&
    !MARKDOWN.test(value) &&
    !URL.test(value) &&
    !MEDICAL_TERMS.test(value) &&
    !COMPETITIVE_TERMS.test(value) &&
    !INSTRUCTIONAL_TERMS.test(value) &&
    !UNSUPPLIED_CLAIM.test(value);
}

function isSafeFinalMessage(value: string): boolean {
  return value.trim().length > 0 && codePointLength(value) <= 160 && sentenceCount(value) <= 2;
}

function sentenceCount(value: string): number {
  const punctuation = value.match(/(?:[!?]+|\.(?=\s|$))/gu)?.length ?? 0;
  return punctuation === 0 ? 1 : punctuation;
}

function codePointLength(value: string): number {
  return Array.from(value).length;
}

function isActionCode(value: unknown): value is HomeGuideActionCode {
  return typeof value === "string" && ACTION_CODES.some((code) => code === value);
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function hasExactKeys(value: Readonly<Record<string, unknown>>, keys: ReadonlySet<string>): boolean {
  return Object.keys(value).length === keys.size && Object.keys(value).every((key) => keys.has(key));
}
