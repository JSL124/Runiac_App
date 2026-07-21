import { HttpsError } from "firebase-functions/v2/https";
import { resolveProfileLevelDisplay, type ProfileLevelDisplay } from "../../progression/profileLevelDisplay.js";

export type FriendLevelsRequest = { readonly auth?: { readonly uid: string }; readonly data: unknown };
export type FriendLevel = ProfileLevelDisplay;
export type FriendLevelsResult = { readonly levels: Readonly<Record<string, FriendLevel>> };
export interface FriendLevelsPorts {
  /**
   * True when the caller has a `users/{callerUid}/friends/{uid}`,
   * `users/{callerUid}/friendRequests/{uid}`, or
   * `users/{callerUid}/blockedUsers/{uid}` edge document for `uid` — i.e. the
   * uid appears on the caller's Friends, Requests, or Blocked tab. This is
   * deliberately looser than the Feed reciprocal-friendship check: it exists
   * to let each of those three list tabs show a level, not to resolve an
   * arbitrary uid.
   */
  hasSocialEdge(callerUid: string, uid: string): Promise<boolean>;
  readProfiles(uids: readonly string[]): Promise<readonly (Readonly<Record<string, unknown>> | undefined)[]>;
}

const MAX_UIDS = 50;

export async function getFriendLevels(request: FriendLevelsRequest, ports: FriendLevelsPorts): Promise<FriendLevelsResult> {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) throw new HttpsError("unauthenticated", "Authentication is required.");
  const requested = parseUids(request.data);
  if (requested === undefined) throw new HttpsError("invalid-argument", "Invalid friend levels request.");
  const unique = [...new Set(requested)];
  if (unique.length > MAX_UIDS) throw new HttpsError("invalid-argument", `At most ${MAX_UIDS} uids may be requested.`);
  if (unique.length === 0) return { levels: {} };
  const permittedFlags = new Map<string, boolean>();
  await Promise.all(unique.map(async (otherUid) => {
    if (otherUid === uid) { permittedFlags.set(otherUid, true); return; }
    permittedFlags.set(otherUid, await ports.hasSocialEdge(uid, otherUid));
  }));
  const permitted = unique.filter((otherUid) => permittedFlags.get(otherUid) === true);
  if (permitted.length === 0) return { levels: {} };
  const profiles = await ports.readProfiles(permitted);
  const levels: Record<string, FriendLevel> = {};
  permitted.forEach((otherUid, index) => { levels[otherUid] = resolveProfileLevelDisplay(profiles[index]); });
  return { levels };
}

function parseUids(raw: unknown): readonly string[] | undefined {
  if (!isRecord(raw) || Object.keys(raw).length !== 1) return undefined;
  const uids = raw["uids"];
  if (!Array.isArray(uids) || !uids.every(isNonEmptyString)) return undefined;
  return uids;
}
function isNonEmptyString(value: unknown): value is string { return typeof value === "string" && value.length > 0; }
function isRecord(value: unknown): value is Readonly<Record<string, unknown>> { return typeof value === "object" && value !== null && !Array.isArray(value); }
