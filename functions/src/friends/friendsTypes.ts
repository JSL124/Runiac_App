import type { Firestore } from "firebase-admin/firestore";

import type { FriendIdentity } from "./nickname.js";

export type FriendsCallableRequest = {
  readonly auth?: { readonly uid: string };
  readonly data: unknown;
};

export type FriendsDependencies = {
  readonly firestore: Firestore;
  readonly nowMs: () => number;
};

export type RequestAction = "accept" | "decline";

export type SocialProfile = {
  readonly identity: FriendIdentity;
  readonly canonicalNickname: string;
};
