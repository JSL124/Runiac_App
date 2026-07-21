import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { getFeedAuthorLevels as getFeedAuthorLevelsCore, type FeedAuthorLevelsPorts } from "./core.js";
import { withCallableErrorReporting } from "../../errors/withErrorReporting.js";

if (getApps().length === 0) initializeApp();

type GetFeedAuthorLevelsRequest = { readonly auth?: { readonly uid: string }; readonly data: unknown };

export const getFeedAuthorLevels = onCall(
  { region: "asia-southeast1" },
  withCallableErrorReporting("getFeedAuthorLevels", async (request: GetFeedAuthorLevelsRequest) => {
    const callableRequest = request.auth === undefined ? { data: request.data } : { auth: { uid: request.auth.uid }, data: request.data };
    return getFeedAuthorLevelsCore(callableRequest, createAuthorLevelsPorts(getFirestore()));
  }),
);

export function createAuthorLevelsPorts(firestore: Firestore): FeedAuthorLevelsPorts {
  return {
    async relationshipFor(viewerUid, authorUid) {
      const [viewerFriend, authorFriend, viewerBlock, authorBlock] = await Promise.all([
        firestore.doc(`users/${viewerUid}/friends/${authorUid}`).get(), firestore.doc(`users/${authorUid}/friends/${viewerUid}`).get(),
        firestore.doc(`users/${viewerUid}/blockedUsers/${authorUid}`).get(), firestore.doc(`users/${authorUid}/blockedUsers/${viewerUid}`).get(),
      ]);
      return { viewerUid, authorUid, viewerHasAuthorFriend: viewerFriend.exists, authorHasViewerFriend: authorFriend.exists, viewerBlockedAuthor: viewerBlock.exists, authorBlockedViewer: authorBlock.exists };
    },
    async readProfiles(uids) {
      if (uids.length === 0) return [];
      const snaps = await firestore.getAll(...uids.map((uid) => firestore.doc(`userProfiles/${uid}`)));
      return snaps.map((snap) => snap.data());
    },
  };
}
