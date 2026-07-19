import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { createFriendsService, type FriendsCallableRequest } from "./friendsCore.js";

if (getApps().length === 0) initializeApp();

function requestForCore(request: { readonly auth?: { readonly uid: string }; readonly data: unknown }): FriendsCallableRequest {
  return request.auth === undefined
    ? { data: request.data }
    : { auth: { uid: request.auth.uid }, data: request.data };
}

export const checkNicknameAvailability = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).checkNicknameAvailability(requestForCore(request)),
);

export const upsertNickname = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).upsertNickname(requestForCore(request)),
);

export const searchFriends = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).search(requestForCore(request)),
);

export const sendFriendRequest = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).sendFriendRequest(requestForCore(request)),
);

export const cancelFriendRequest = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).cancelFriendRequest(requestForCore(request)),
);

export const respondToFriendRequest = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).respondToFriendRequest(requestForCore(request)),
);

export const removeFriend = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).removeFriend(requestForCore(request)),
);

export const blockUser = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).blockUser(requestForCore(request)),
);

export const unblockUser = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).unblockUser(requestForCore(request)),
);

export const migrateUnicodeNicknameClaims = onCall({ region: "asia-southeast1" }, async (request) =>
  createFriendsService({ firestore: getFirestore() }).migrateUnicodeNicknameClaims(requestForCore(request)),
);
