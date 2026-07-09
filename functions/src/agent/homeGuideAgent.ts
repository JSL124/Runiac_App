/**
 * Home-screen "Runiac guide" agent callable.
 *
 * Trust boundary: this callable produces a *display-only* narrative string.
 * It must never compute or return XP, level, rank, streak, leaderboard, or
 * subscription/expert-plan publication values -- those remain server-owned
 * elsewhere (see functions/src/run/completeRun.ts). The request payload is
 * restricted to values the client already renders on the Home screen (plan
 * copy, workout labels, durations); no GPS traces, no free-form user text,
 * no sensitive profile data ever reach this callable or the model prompt.
 *
 * The OpenAI API key is read exclusively server-side via a Firebase secret
 * (see OPENAI_API_KEY below) or, in the emulator only, from
 * process.env.OPENAI_API_KEY. It is never sent to, stored in, or reachable
 * from the Flutter client.
 */
import { Annotation, END, START, StateGraph } from "@langchain/langgraph";
import { HumanMessage, SystemMessage } from "@langchain/core/messages";
import { ChatOpenAI } from "@langchain/openai";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

export const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

type CallableGuideRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

export type HomeGuideAgentPayload = {
  readonly planTitle: string;
  readonly weekNumber: number;
  readonly weekFocus: string;
  readonly dayLabel: string;
  readonly workoutTitle: string;
  readonly durationMinutes: number;
  readonly intensity: string;
  readonly description: string;
  readonly steps: readonly string[];
  readonly supportiveNote: string;
};

export type HomeGuideAgentResult = {
  readonly message: string | null;
  readonly source: "agent" | "unavailable";
};

const MAX_MESSAGE_LENGTH = 600;
const MAX_STEPS = 12;
const MAX_STEP_LENGTH = 200;
const MAX_TEXT_FIELD_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 800;

const allowedKeys = new Set([
  "planTitle",
  "weekNumber",
  "weekFocus",
  "dayLabel",
  "workoutTitle",
  "durationMinutes",
  "intensity",
  "description",
  "steps",
  "supportiveNote",
]);

/**
 * The character IS Runiac's running guide agent -- a friendly,
 * beginner-focused running coach embedded in the Runiac app. It never
 * invents backend-owned numbers (XP, level, rank, streak, leaderboard) and
 * never makes medical claims.
 */
export const HOME_GUIDE_SYSTEM_PROMPT = [
  "You are Runiac's running guide agent: a friendly, encouraging, beginner-focused running coach character embedded in the Runiac app's Home screen.",
  "Explain today's planned workout warmly in 2-4 short sentences.",
  "Mention the workout duration and give simple, safety-first pacing guidance suited to a beginner.",
  "Be encouraging and supportive in tone, never intimidating.",
  "Never invent or state XP, level, rank, streak, or leaderboard numbers -- those are not yours to report.",
  "Never make medical claims or give medical advice; if relevant, suggest the runner listen to their body and stop if something feels wrong.",
  "Respond in the same language as the workout copy you were given (English unless the input text indicates otherwise).",
  "Keep the response concise: no more than about four sentences.",
].join(" ");

const GraphState = Annotation.Root({
  systemPrompt: Annotation<string>(),
  userPrompt: Annotation<string>(),
  message: Annotation<string | null>(),
});

export const homeGuideAgent = onCall(
  { region: "asia-southeast1", secrets: [OPENAI_API_KEY] },
  async (request) => homeGuideAgentForCallable(request, resolveOpenAiApiKey()),
);

export async function homeGuideAgentForCallable(
  request: CallableGuideRequest,
  apiKey: string | undefined,
): Promise<HomeGuideAgentResult> {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required to use the home guide agent.");
  }

  const payload = parseHomeGuideAgentPayload(request.data);

  if (apiKey === undefined || apiKey.length === 0) {
    return { message: null, source: "unavailable" };
  }

  try {
    const { systemPrompt, userPrompt } = buildHomeGuideGraphInput(payload);
    const graph = buildHomeGuideGraph(apiKey);
    const result = await graph.invoke({ systemPrompt, userPrompt, message: null });
    const message = result.message;

    if (message === null || message === undefined || message.trim().length === 0) {
      return { message: null, source: "unavailable" };
    }

    return { message: clampAgentMessage(message), source: "agent" };
  } catch (error) {
    console.error("homeGuideAgent: falling back after model/graph failure", error);
    return { message: null, source: "unavailable" };
  }
}

/**
 * Reads the OpenAI key from the bound Firebase secret; falls back to
 * process.env.OPENAI_API_KEY only for local emulator runs.
 */
function resolveOpenAiApiKey(): string | undefined {
  try {
    const secretValue = OPENAI_API_KEY.value();
    if (secretValue.length > 0) {
      return secretValue;
    }
  } catch {
    // defineSecret().value() throws outside a deployed/bound context (e.g. emulator).
  }

  return process.env["OPENAI_API_KEY"];
}

function buildHomeGuideGraph(apiKey: string) {
  const model = new ChatOpenAI({
    apiKey,
    model: "gpt-4o-mini",
    temperature: 0.6,
    maxTokens: 220,
  });

  const graph = new StateGraph(GraphState)
    .addNode("guideModel", async (state) => {
      const response = await model.invoke([
        new SystemMessage(state.systemPrompt),
        new HumanMessage(state.userPrompt),
      ]);
      const content = typeof response.content === "string" ? response.content : stringifyMessageContent(response.content);
      return { message: content };
    })
    .addEdge(START, "guideModel")
    .addEdge("guideModel", END);

  return graph.compile();
}

function stringifyMessageContent(content: unknown): string {
  if (Array.isArray(content)) {
    return content
      .map((part) => (typeof part === "object" && part !== null && "text" in part ? String((part as { text: unknown }).text) : ""))
      .join(" ")
      .trim();
  }
  return "";
}

/** Clamps a model response to a sane display length without cutting mid-word where avoidable. */
export function clampAgentMessage(message: string): string {
  const trimmed = message.trim();
  if (trimmed.length <= MAX_MESSAGE_LENGTH) {
    return trimmed;
  }

  const truncated = trimmed.slice(0, MAX_MESSAGE_LENGTH);
  const lastSpace = truncated.lastIndexOf(" ");
  const safeCut = lastSpace > MAX_MESSAGE_LENGTH * 0.6 ? truncated.slice(0, lastSpace) : truncated;
  return `${safeCut.trimEnd()}...`;
}

/** Builds the graph's system/user prompt inputs from a validated payload. Pure, no network calls. */
export function buildHomeGuideGraphInput(payload: HomeGuideAgentPayload): {
  readonly systemPrompt: string;
  readonly userPrompt: string;
} {
  const stepsList = payload.steps.length > 0 ? payload.steps.map((step, index) => `${index + 1}. ${step}`).join("\n") : "(no step breakdown provided)";

  const userPrompt = [
    `Plan: ${payload.planTitle}`,
    `Week ${payload.weekNumber} focus: ${payload.weekFocus}`,
    `Today: ${payload.dayLabel}`,
    `Workout: ${payload.workoutTitle} (${payload.durationMinutes} minutes, ${payload.intensity} intensity)`,
    `Description: ${payload.description}`,
    `Steps:\n${stepsList}`,
    `Supportive note from the plan: ${payload.supportiveNote}`,
    "Explain this workout warmly to the runner as their Runiac guide, in 2-4 short sentences.",
  ].join("\n");

  return { systemPrompt: HOME_GUIDE_SYSTEM_PROMPT, userPrompt };
}

/** Validates and narrows the raw callable payload. Rejects unknown/protected fields and bad types. */
export function parseHomeGuideAgentPayload(data: unknown): HomeGuideAgentPayload {
  if (!isRecord(data)) {
    throw invalid("Payload must be an object.");
  }

  for (const key of Object.keys(data)) {
    if (!allowedKeys.has(key)) {
      throw invalid(`Unsupported field is not accepted: ${key}.`);
    }
  }

  return {
    planTitle: readNonEmptyString(data, "planTitle", MAX_TEXT_FIELD_LENGTH),
    weekNumber: readPositiveInteger(data, "weekNumber"),
    weekFocus: readNonEmptyString(data, "weekFocus", MAX_TEXT_FIELD_LENGTH),
    dayLabel: readNonEmptyString(data, "dayLabel", MAX_TEXT_FIELD_LENGTH),
    workoutTitle: readNonEmptyString(data, "workoutTitle", MAX_TEXT_FIELD_LENGTH),
    durationMinutes: readPositiveInteger(data, "durationMinutes"),
    intensity: readNonEmptyString(data, "intensity", MAX_TEXT_FIELD_LENGTH),
    description: readNonEmptyString(data, "description", MAX_DESCRIPTION_LENGTH),
    steps: readStepsArray(data, "steps"),
    supportiveNote: readNonEmptyString(data, "supportiveNote", MAX_TEXT_FIELD_LENGTH),
  };
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readNonEmptyString(data: Readonly<Record<string, unknown>>, key: string, maxLength: number): string {
  const value = data[key];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw invalid(`${key} must be a non-empty string.`);
  }
  if (value.length > maxLength) {
    throw invalid(`${key} must be at most ${maxLength} characters.`);
  }
  return value;
}

function readPositiveInteger(data: Readonly<Record<string, unknown>>, key: string): number {
  const value = data[key];
  if (typeof value !== "number" || !Number.isInteger(value) || value <= 0) {
    throw invalid(`${key} must be a positive integer.`);
  }
  return value;
}

function readStepsArray(data: Readonly<Record<string, unknown>>, key: string): readonly string[] {
  const value = data[key];
  if (!Array.isArray(value)) {
    throw invalid(`${key} must be an array of strings.`);
  }
  if (value.length > MAX_STEPS) {
    throw invalid(`${key} must contain at most ${MAX_STEPS} items.`);
  }
  return value.map((item, index) => {
    if (typeof item !== "string" || item.trim().length === 0) {
      throw invalid(`${key}[${index}] must be a non-empty string.`);
    }
    if (item.length > MAX_STEP_LENGTH) {
      throw invalid(`${key}[${index}] must be at most ${MAX_STEP_LENGTH} characters.`);
    }
    return item;
  });
}

function invalid(message: string): HttpsError {
  return new HttpsError("invalid-argument", message);
}
