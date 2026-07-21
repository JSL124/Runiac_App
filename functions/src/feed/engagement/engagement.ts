import { getApps, initializeApp } from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
  type Firestore,
} from "firebase-admin/firestore";
import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { withTriggerErrorReporting } from "../../errors/withErrorReporting.js";

type FeedPostEvent = { readonly params: { readonly postId: string } };

export const engagementKinds = ["like", "comment"] as const;

export type EngagementKind = (typeof engagementKinds)[number];

export type EngagementUpdate<TUpdatedAt> =
  | { readonly likeCount: number; readonly updatedAt: TUpdatedAt }
  | { readonly commentCount: number; readonly updatedAt: TUpdatedAt };

export type EngagementAggregationPort<TUpdatedAt> = {
  readonly recomputePublishedCount: (input: {
    readonly postId: string;
    readonly kind: EngagementKind;
    readonly updatedAt: TUpdatedAt;
  }) => Promise<EngagementRecomputeResult>;
};

export type EngagementRecomputeResult =
  | { readonly kind: "updated"; readonly count: number }
  | { readonly kind: "parent_not_published" };

export type FeedEngagementHandlers = {
  readonly onLikeCreated: (postId: string) => Promise<EngagementRecomputeResult>;
  readonly onLikeDeleted: (postId: string) => Promise<EngagementRecomputeResult>;
  readonly onCommentCreated: (postId: string) => Promise<EngagementRecomputeResult>;
  readonly onCommentUpdated: (postId: string) => Promise<EngagementRecomputeResult>;
  readonly onCommentDeleted: (postId: string) => Promise<EngagementRecomputeResult>;
};

export async function recomputeFeedEngagementCount<TUpdatedAt>(
  port: EngagementAggregationPort<TUpdatedAt>,
  input: { readonly postId: string; readonly kind: EngagementKind; readonly updatedAt: TUpdatedAt },
): Promise<EngagementRecomputeResult> {
  return port.recomputePublishedCount(input);
}

export function createFeedEngagementHandlers<TUpdatedAt>(
  dependencies: {
    readonly port: EngagementAggregationPort<TUpdatedAt>;
    readonly updatedAt: () => TUpdatedAt;
  },
): FeedEngagementHandlers {
  const recompute = (postId: string, kind: EngagementKind): Promise<EngagementRecomputeResult> =>
    recomputeFeedEngagementCount(dependencies.port, {
      postId,
      kind,
      updatedAt: dependencies.updatedAt(),
    });
  return {
    onLikeCreated: (postId) => recompute(postId, "like"),
    onLikeDeleted: (postId) => recompute(postId, "like"),
    onCommentCreated: (postId) => recompute(postId, "comment"),
    onCommentUpdated: (postId) => recompute(postId, "comment"),
    onCommentDeleted: (postId) => recompute(postId, "comment"),
  };
}

export function firestoreEngagementAggregationPort(
  firestore: Firestore,
): EngagementAggregationPort<FieldValue> {
  return {
    recomputePublishedCount: async (input) =>
      firestore.runTransaction(async (transaction) => {
        const post = firestore.collection("feedPosts").doc(input.postId);
        const parent = await transaction.get(post);
        if (!parent.exists || parent.get("status") !== "published") {
          return { kind: "parent_not_published" };
        }
        const aggregate = await transaction.get(
          post.collection(collectionName(input.kind)).count(),
        );
        const count = Math.max(0, aggregate.data().count);
        const update = updateFor(input.kind, count, input.updatedAt);
        transaction.update(post, update);
        return { kind: "updated", count };
      }),
  };
}

export function createFeedEngagementTriggers(dependencies: {
  readonly firestore: Firestore;
  readonly updatedAt: () => FieldValue;
}) {
  const handlers = createFeedEngagementHandlers({
    port: firestoreEngagementAggregationPort(dependencies.firestore),
    updatedAt: dependencies.updatedAt,
  });
  return {
    feedLikeCreated: onDocumentCreated(
      {
        document: "feedPosts/{postId}/likes/{uid}",
        region: "asia-southeast1",
      },
      withTriggerErrorReporting("feedLikeCreated", async (event: FeedPostEvent) => {
        await handlers.onLikeCreated(event.params.postId);
      }),
    ),
    feedLikeDeleted: onDocumentDeleted(
      {
        document: "feedPosts/{postId}/likes/{uid}",
        region: "asia-southeast1",
      },
      withTriggerErrorReporting("feedLikeDeleted", async (event: FeedPostEvent) => {
        await handlers.onLikeDeleted(event.params.postId);
      }),
    ),
    feedCommentCreated: onDocumentCreated(
      {
        document: "feedPosts/{postId}/comments/{commentId}",
        region: "asia-southeast1",
      },
      withTriggerErrorReporting("feedCommentCreated", async (event: FeedPostEvent) => {
        await handlers.onCommentCreated(event.params.postId);
      }),
    ),
    feedCommentUpdated: onDocumentUpdated(
      {
        document: "feedPosts/{postId}/comments/{commentId}",
        region: "asia-southeast1",
      },
      withTriggerErrorReporting("feedCommentUpdated", async (event: FeedPostEvent) => {
        await handlers.onCommentUpdated(event.params.postId);
      }),
    ),
    feedCommentDeleted: onDocumentDeleted(
      {
        document: "feedPosts/{postId}/comments/{commentId}",
        region: "asia-southeast1",
      },
      withTriggerErrorReporting("feedCommentDeleted", async (event: FeedPostEvent) => {
        await handlers.onCommentDeleted(event.params.postId);
      }),
    ),
  };
}

if (getApps().length === 0) {
  initializeApp();
}

const productionFeedEngagementTriggers = createFeedEngagementTriggers({
  firestore: getFirestore(),
  updatedAt: () => FieldValue.serverTimestamp(),
});

export const feedLikeCreated = productionFeedEngagementTriggers.feedLikeCreated;
export const feedLikeDeleted = productionFeedEngagementTriggers.feedLikeDeleted;
export const feedCommentCreated = productionFeedEngagementTriggers.feedCommentCreated;
export const feedCommentUpdated = productionFeedEngagementTriggers.feedCommentUpdated;
export const feedCommentDeleted = productionFeedEngagementTriggers.feedCommentDeleted;

function collectionName(kind: EngagementKind): "likes" | "comments" {
  switch (kind) {
    case "like":
      return "likes";
    case "comment":
      return "comments";
  }
}

function updateFor<TUpdatedAt>(
  kind: EngagementKind,
  count: number,
  updatedAt: TUpdatedAt,
): EngagementUpdate<TUpdatedAt> {
  switch (kind) {
    case "like":
      return { likeCount: count, updatedAt };
    case "comment":
      return { commentCount: count, updatedAt };
  }
}
