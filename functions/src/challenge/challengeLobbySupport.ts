import {
  Timestamp,
  type Firestore,
  type Transaction,
} from "firebase-admin/firestore";
import type {
  DocumentData,
  DocumentReference,
  Query,
  QuerySnapshot,
} from "firebase-admin/firestore";
import { evaluateFeedRelationship } from "../feed/relationship.js";
import { isChallengeTierId } from "./challengeCatalog.js";
import type {
  ChallengeRulesSnapshot,
  ChallengeTierId,
} from "./challengeTypes.js";
import { challengeError } from "./challengeErrors.js";

export type CallableRequest = {
  readonly auth?: { readonly uid: string };
  readonly data: unknown;
};

export function instanceRef(
  firestore: Firestore,
  challengeId: string,
): DocumentReference {
  return firestore.collection("challengeInstances").doc(challengeId);
}
export function participantRef(
  firestore: Firestore,
  challengeId: string,
  uid: string,
): DocumentReference {
  return instanceRef(firestore, challengeId)
    .collection("participants")
    .doc(uid);
}
export function participantsQuery(
  firestore: Firestore,
  challengeId: string,
): Query {
  return instanceRef(firestore, challengeId).collection("participants");
}
export function invitationRef(
  firestore: Firestore,
  inviteId: string,
): DocumentReference {
  return firestore.collection("challengeInvitations").doc(inviteId);
}
export function invitationsForChallengeQuery(
  firestore: Firestore,
  challengeId: string,
): Query {
  return firestore
    .collection("challengeInvitations")
    .where("challengeId", "==", challengeId);
}
export function slotRef(firestore: Firestore, uid: string): DocumentReference {
  return firestore.collection("challengeSlots").doc(uid);
}
export function profileRef(firestore: Firestore, uid: string): DocumentReference {
  return firestore.collection("userProfiles").doc(uid);
}
export function friendRef(
  firestore: Firestore,
  ownerUid: string,
  otherUid: string,
): DocumentReference {
  return firestore.doc(`users/${ownerUid}/friends/${otherUid}`);
}
export function blockRef(
  firestore: Firestore,
  ownerUid: string,
  otherUid: string,
): DocumentReference {
  return firestore.doc(`users/${ownerUid}/blockedUsers/${otherUid}`);
}

export function invitationId(challengeId: string, recipientUid: string): string {
  return `${challengeId}__${recipientUid}`;
}

export function asRecord(value: unknown): Readonly<Record<string, unknown>> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw challengeError("INVALID_ARGUMENT");
  }
  return value as Readonly<Record<string, unknown>>;
}

export function requireAuthUid(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw challengeError("UNAUTHENTICATED");
  }
  return uid;
}

export function requireTierId(data: unknown): ChallengeTierId {
  const record = asRecord(data);
  const tierId = record["tierId"];
  if (typeof tierId !== "string") throw challengeError("INVALID_ARGUMENT");
  if (!isChallengeTierId(tierId)) throw challengeError("UNKNOWN_TIER");
  return tierId;
}

export function requireChallengeId(data: unknown): string {
  const record = asRecord(data);
  const challengeId = record["challengeId"];
  if (typeof challengeId !== "string" || challengeId.length === 0) {
    throw challengeError("INVALID_ARGUMENT");
  }
  return challengeId;
}

export function requireInviteId(data: unknown): string {
  const record = asRecord(data);
  const inviteId = record["inviteId"];
  if (typeof inviteId !== "string" || inviteId.length === 0) {
    throw challengeError("INVALID_ARGUMENT");
  }
  return inviteId;
}

export function requireInviteeUids(data: unknown): readonly string[] {
  const record = asRecord(data);
  const uids = record["uids"];
  if (!Array.isArray(uids) || uids.length === 0) {
    throw challengeError("INVALID_ARGUMENT");
  }
  const seen = new Set<string>();
  for (const value of uids) {
    if (typeof value !== "string" || value.length === 0) {
      throw challengeError("INVALID_ARGUMENT");
    }
    seen.add(value);
  }
  return [...seen];
}

export function requireResponse(data: unknown): "accept" | "decline" {
  const record = asRecord(data);
  const response = record["response"];
  if (response === "accept" || response === "decline") return response;
  throw challengeError("INVALID_ARGUMENT");
}

export function readString(data: DocumentData | undefined, key: string): string {
  const value = data?.[key];
  return typeof value === "string" ? value : "";
}

export function readNumber(data: DocumentData | undefined, key: string): number {
  const value = data?.[key];
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

export function readRoster(data: DocumentData | undefined): readonly string[] {
  const value = data?.["rosterUids"];
  if (!Array.isArray(value)) return [];
  return value.filter((entry): entry is string => typeof entry === "string");
}

export function readRules(
  data: DocumentData | undefined,
): ChallengeRulesSnapshot | undefined {
  const value = data?.["rules"];
  if (typeof value !== "object" || value === null) return undefined;
  return value as ChallengeRulesSnapshot;
}

export function timestampToMillis(value: unknown): number {
  if (value instanceof Timestamp) return value.toMillis();
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "object" && value !== null) {
    const seconds = (value as { readonly _seconds?: unknown })._seconds;
    if (typeof seconds === "number") return seconds * 1000;
  }
  return 0;
}

export async function readReciprocalRelationship(
  transaction: Transaction,
  firestore: Firestore,
  viewerUid: string,
  authorUid: string,
): Promise<ReturnType<typeof evaluateFeedRelationship>> {
  const [viewerFriend, authorFriend, viewerBlock, authorBlock] =
    await Promise.all([
      transaction.get(friendRef(firestore, viewerUid, authorUid)),
      transaction.get(friendRef(firestore, authorUid, viewerUid)),
      transaction.get(blockRef(firestore, viewerUid, authorUid)),
      transaction.get(blockRef(firestore, authorUid, viewerUid)),
    ]);
  return evaluateFeedRelationship({
    viewerUid,
    authorUid,
    viewerHasAuthorFriend: viewerFriend.exists,
    authorHasViewerFriend: authorFriend.exists,
    viewerBlockedAuthor: viewerBlock.exists,
    authorBlockedViewer: authorBlock.exists,
  });
}

export type ChallengeInstanceView = {
  readonly challengeId: string;
  readonly ownerUid: string;
  readonly tierId: string;
  readonly catalogVersion: string;
  readonly mode: string;
  readonly status: string;
  readonly rules: ChallengeRulesSnapshot | null;
  readonly rosterUids: readonly string[];
  readonly maxParticipants: number;
  readonly teamMeters: number;
  readonly createdAtMs: number;
  readonly lobbyExpiresAtMs: number;
  readonly startsAtMs: number | null;
  readonly scheduledEndsAtMs: number | null;
  readonly terminalReason: string | null;
};

export type ChallengeParticipantView = {
  readonly uid: string;
  readonly role: string;
  readonly status: string;
  readonly creditedMeters: number;
  readonly reward: string;
  readonly displayNameSnapshot: string;
  readonly avatarInitialsSnapshot: string;
};

export function serializeInstance(
  challengeId: string,
  data: DocumentData,
): ChallengeInstanceView {
  const startsAt = data["startsAt"];
  const scheduledEndsAt = data["scheduledEndsAt"];
  const terminalReason = data["terminalReason"];
  return {
    challengeId,
    ownerUid: readString(data, "ownerUid"),
    tierId: readString(data, "tierId"),
    catalogVersion: readString(data, "catalogVersion"),
    mode: readString(data, "mode"),
    status: readString(data, "status"),
    rules: readRules(data) ?? null,
    rosterUids: readRoster(data),
    maxParticipants: readNumber(data, "maxParticipants"),
    teamMeters: readNumber(data, "teamMeters"),
    createdAtMs: timestampToMillis(data["createdAt"]),
    lobbyExpiresAtMs: timestampToMillis(data["lobbyExpiresAt"]),
    startsAtMs: startsAt === undefined ? null : timestampToMillis(startsAt),
    scheduledEndsAtMs:
      scheduledEndsAt === undefined
        ? null
        : timestampToMillis(scheduledEndsAt),
    terminalReason: typeof terminalReason === "string" ? terminalReason : null,
  };
}

export function serializeParticipant(
  data: DocumentData,
): ChallengeParticipantView {
  return {
    uid: readString(data, "uid"),
    role: readString(data, "role"),
    status: readString(data, "status"),
    creditedMeters: readNumber(data, "creditedMeters"),
    reward: readString(data, "reward"),
    displayNameSnapshot: readString(data, "displayNameSnapshot"),
    avatarInitialsSnapshot: readString(data, "avatarInitialsSnapshot"),
  };
}

export function sortedParticipantViews(
  snapshot: QuerySnapshot,
): readonly ChallengeParticipantView[] {
  return snapshot.docs
    .map((doc) => serializeParticipant(doc.data()))
    .sort((left, right) => left.uid.localeCompare(right.uid));
}
