const weekdayOffsets: Readonly<Record<string, number>> = {
  Mon: 0,
  Tue: 1,
  Wed: 2,
  Thu: 3,
  Fri: 4,
  Sat: 5,
  Sun: 6,
} as const;

export const weekdayLabels: readonly string[] = Object.keys(weekdayOffsets);

export function scheduledDateFor(
  startsOnDate: string | undefined,
  weekNumber: number,
  dayLabel: string,
): string | null {
  if (startsOnDate === undefined) {
    return null;
  }

  const weekdayOffset = weekdayOffsets[dayLabel];
  if (weekdayOffset === undefined) {
    return null;
  }

  const startTime = Date.parse(`${startsOnDate}T00:00:00.000Z`);
  if (Number.isNaN(startTime)) {
    return null;
  }

  const millisecondsPerDay = 86_400_000;
  const date = new Date(startTime + ((weekNumber - 1) * 7 + weekdayOffset) * millisecondsPerDay);
  return date.toISOString().slice(0, 10);
}

export function fallbackWorkoutId(weekNumber: number, dayLabel: string, title: string): string {
  const titleSlug = title.toLowerCase().replaceAll(/[^a-z0-9]+/g, "-").replaceAll(/^-|-$/g, "");
  return `week-${weekNumber}-${dayLabel.toLowerCase()}-${titleSlug || "workout"}`;
}

export function datePart(isoDate: string): string {
  return isoDate.slice(0, 10);
}

export function readOptionalString(value: unknown): string | undefined {
  if (typeof value !== "string" || value.trim().length === 0) {
    return undefined;
  }
  return value;
}

export function readOptionalInteger(value: unknown): number | undefined {
  if (typeof value !== "number" || !Number.isInteger(value)) {
    return undefined;
  }

  return value;
}

export function readOptionalPositiveNumber(value: unknown): number | undefined {
  if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) {
    return undefined;
  }

  return value;
}

export function isRestWorkout(value: Readonly<Record<string, unknown>>): boolean {
  const kind = readOptionalString(value["kind"]);
  return kind === "rest" || kind === "restDay";
}

export function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
