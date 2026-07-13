// Challenge callable production surface.
//
// Thin onCall wrappers (region asia-southeast1, same registration/emulator style
// as completeRun) that delegate to the transaction cores. Each maps the raw
// callable request onto the minimal `{ auth?: { uid }, data }` contract, then
// runs against the live Firestore. All authentication, idempotency, and stable
// reason codes live in the cores.

import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import {
  cancelChallengeLobbyForCallable,
  createChallengeLobbyForCallable,
  getActiveChallengeForCallable,
  getChallengeCatalogForCallable,
  getChallengeInvitationsForCallable,
  inviteChallengeFriendsForCallable,
  respondToChallengeInvitationForCallable,
  startChallengeForCallable,
  withdrawFromChallengeLobbyForCallable,
  type CallableRequest,
} from "./challengeLobbyCore.js";
import {
  abandonChallengeForCallable,
  leaveChallengeForCallable,
} from "./challengeSettlementCore.js";

if (getApps().length === 0) initializeApp();

function normalize(request: { readonly auth?: { readonly uid: string }; readonly data: unknown }): CallableRequest {
  return request.auth === undefined
    ? { data: request.data }
    : { auth: { uid: request.auth.uid }, data: request.data };
}

export const getChallengeCatalog = onCall({ region: "asia-southeast1" }, async (request) =>
  getChallengeCatalogForCallable(normalize(request)),
);

export const createChallengeLobby = onCall({ region: "asia-southeast1" }, async (request) =>
  createChallengeLobbyForCallable(normalize(request), getFirestore()),
);

export const inviteChallengeFriends = onCall({ region: "asia-southeast1" }, async (request) =>
  inviteChallengeFriendsForCallable(normalize(request), getFirestore()),
);

export const respondToChallengeInvitation = onCall({ region: "asia-southeast1" }, async (request) =>
  respondToChallengeInvitationForCallable(normalize(request), getFirestore()),
);

export const withdrawFromChallengeLobby = onCall({ region: "asia-southeast1" }, async (request) =>
  withdrawFromChallengeLobbyForCallable(normalize(request), getFirestore()),
);

export const cancelChallengeLobby = onCall({ region: "asia-southeast1" }, async (request) =>
  cancelChallengeLobbyForCallable(normalize(request), getFirestore()),
);

export const startChallenge = onCall({ region: "asia-southeast1" }, async (request) =>
  startChallengeForCallable(normalize(request), getFirestore()),
);

export const getActiveChallenge = onCall({ region: "asia-southeast1" }, async (request) =>
  getActiveChallengeForCallable(normalize(request), getFirestore()),
);

export const getChallengeInvitations = onCall({ region: "asia-southeast1" }, async (request) =>
  getChallengeInvitationsForCallable(normalize(request), getFirestore()),
);

export const leaveChallenge = onCall({ region: "asia-southeast1" }, async (request) =>
  leaveChallengeForCallable(normalize(request), getFirestore()),
);

export const abandonChallenge = onCall({ region: "asia-southeast1" }, async (request) =>
  abandonChallengeForCallable(normalize(request), getFirestore()),
);
