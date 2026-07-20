import { getApps, initializeApp } from "firebase-admin/app";
import {
  getFirestore,
  type DocumentData,
  type Firestore,
} from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { refreshMonthlyLeaderboardSnapshots } from "./monthlyLeaderboard.js";

// The admin console (Next.js server, Admin SDK only) cannot invoke Cloud
// Functions callables directly, so "request a recalculation" has to be a
// Firestore write + trigger handoff instead of a callable: the console
// creates a `leaderboardAdminCommands/{commandId}` document, this trigger
// consumes it and runs the real aggregation, then merge-writes the outcome
// back onto the SAME document. `onDocumentCreated` fires only on create, so
// that write-back does not re-trigger this function.
const leaderboardAdminCommandsCollection = "leaderboardAdminCommands";
const periodKeyPattern = /^\d{4}-\d{2}$/;

export type LeaderboardAdminCommandHandlers = {
  readonly onCommandCreated: (
    commandId: string,
    data: DocumentData,
  ) => Promise<void>;
};

export function createLeaderboardAdminCommandHandlers(dependencies: {
  readonly firestore: Firestore;
}): LeaderboardAdminCommandHandlers {
  return {
    onCommandCreated: async (commandId, data) => {
      const ref = dependencies.firestore
        .collection(leaderboardAdminCommandsCollection)
        .doc(commandId);
      const command = readString(data["command"]);
      const periodKey = readString(data["periodKey"]);

      if (
        command !== "refresh" ||
        periodKey === null ||
        !periodKeyPattern.test(periodKey)
      ) {
        // Invalid input is a business denial, not an infrastructure fault:
        // merge-write a rejection and return without throwing.
        await ref.set(
          {
            status: "rejected",
            error: rejectionReason(command, data),
            completedAt: new Date().toISOString(),
          },
          { merge: true },
        );
        return;
      }

      try {
        // Reused as-is: this already claims the
        // leaderboardAggregationLocks/monthly_{periodKey} lease, so locking is
        // not reimplemented here.
        const result = await refreshMonthlyLeaderboardSnapshots(
          dependencies.firestore,
          periodKey,
        );
        await ref.set(
          {
            status: result.status,
            buildId: result.buildId,
            snapshotCount: result.snapshotCount,
            rankCount: result.rankCount,
            currentViewCount: result.currentViewCount,
            completedAt: new Date().toISOString(),
          },
          { merge: true },
        );
      } catch (error) {
        await ref.set(
          {
            status: "failed",
            error: error instanceof Error ? error.message : String(error),
            completedAt: new Date().toISOString(),
          },
          { merge: true },
        );
        // Rethrow so the fault surfaces in Cloud Logging.
        throw error;
      }
    },
  };
}

export function createLeaderboardAdminCommandTriggers(dependencies: {
  readonly firestore: Firestore;
}) {
  const handlers = createLeaderboardAdminCommandHandlers(dependencies);
  return {
    leaderboardAdminCommandCreated: onDocumentCreated(
      {
        document: `${leaderboardAdminCommandsCollection}/{commandId}`,
        region: "asia-southeast1",
      },
      async (event) => {
        const data = event.data?.data();
        if (data === undefined) {
          return;
        }
        await handlers.onCommandCreated(event.params.commandId, data);
      },
    ),
  };
}

if (getApps().length === 0) {
  initializeApp();
}

const productionLeaderboardAdminCommandTriggers =
  createLeaderboardAdminCommandTriggers({
    firestore: getFirestore(),
  });

export const leaderboardAdminCommandCreated =
  productionLeaderboardAdminCommandTriggers.leaderboardAdminCommandCreated;

function rejectionReason(
  command: string | null,
  data: DocumentData,
): string {
  if (command !== "refresh") {
    return `Unsupported command: ${String(data["command"])}`;
  }
  return `Malformed periodKey: ${String(data["periodKey"])}`;
}

function readString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : null;
}
