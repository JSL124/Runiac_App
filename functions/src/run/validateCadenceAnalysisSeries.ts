import { HttpsError } from "firebase-functions/v2/https";
import type { CadenceAnalysisSeriesPayload } from "./runCompletionTypes.js";

const minCadenceSpm = 90;
const maxCadenceSpm = 220;
const maxCadenceSampleCount = 720;

export function readOptionalCadenceAnalysisSeries(
  data: Readonly<Record<string, unknown>>,
): CadenceAnalysisSeriesPayload | undefined {
  const value = data["cadenceAnalysisSeries"];
  if (value === undefined) {
    return undefined;
  }
  if (!isRecord(value)) {
    throw invalid("cadenceAnalysisSeries must be an object when provided.");
  }

  const source = readString(value, "source");
  if (source !== "phoneSensorEstimated") {
    throw invalid("cadenceAnalysisSeries.source must be phoneSensorEstimated.");
  }
  const confidence = readString(value, "confidence");
  if (confidence !== "low") {
    throw invalid("cadenceAnalysisSeries.confidence must be low.");
  }
  const rawSamples = value["samples"];
  if (
    !Array.isArray(rawSamples) ||
    rawSamples.length === 0 ||
    rawSamples.length > maxCadenceSampleCount
  ) {
    throw invalid("cadenceAnalysisSeries.samples must be a non-empty bounded array.");
  }

  return {
    source,
    confidence,
    samples: rawSamples.map(readCadenceAnalysisSample),
  };
}

function readCadenceAnalysisSample(
  value: unknown,
): CadenceAnalysisSeriesPayload["samples"][number] {
  if (!isRecord(value)) {
    throw invalid("cadenceAnalysisSeries.samples entries must be objects.");
  }
  const elapsedSeconds = readNonNegativeNumber(value, "elapsedSeconds");
  const cadenceSpm = readNonNegativeNumber(value, "cadenceSpm");
  const status = readString(value, "status");
  if (status !== "accepted") {
    throw invalid("cadenceAnalysisSeries.samples status must be accepted.");
  }
  if (cadenceSpm < minCadenceSpm || cadenceSpm > maxCadenceSpm) {
    throw invalid("cadenceAnalysisSeries.samples cadenceSpm is outside safety limits.");
  }
  return { elapsedSeconds, cadenceSpm, status };
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readString(data: Readonly<Record<string, unknown>>, key: string): string {
  const value = data[key];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw invalid(`${key} must be a non-empty string.`);
  }
  return value;
}

function readNonNegativeNumber(data: Readonly<Record<string, unknown>>, key: string): number {
  const value = data[key];
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0) {
    throw invalid(`${key} must be a non-negative number.`);
  }
  return value;
}

function invalid(message: string): HttpsError {
  return new HttpsError("invalid-argument", message);
}
