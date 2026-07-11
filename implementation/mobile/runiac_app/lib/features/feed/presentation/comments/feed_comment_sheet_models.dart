import '../../domain/models/feed_display_models.dart';

List<FeedCommentReadModel> sessionCommentModels({
  required List<String> comments,
  required String authorUserId,
}) => List.generate(
  comments.length,
  (index) => FeedCommentReadModel(
    commentId: 'session-$index',
    authorUserId: authorUserId,
    authorDisplayName: 'You',
    authorAvatarInitials: 'YO',
    body: comments[index],
    createdAt: DateTime.fromMillisecondsSinceEpoch(index),
  ),
).reversed.toList(growable: false);

FeedCommentCursor? lastCommentCursor(List<FeedCommentReadModel> comments) =>
    comments.isEmpty
    ? null
    : FeedCommentCursor(
        createdAt: comments.last.createdAt,
        commentId: comments.last.commentId,
      );

List<FeedCommentReadModel> replaceCommentBody({
  required List<FeedCommentReadModel> comments,
  required String commentId,
  required String body,
}) => comments
    .map((item) => item.commentId == commentId ? item.copyWith(body: body) : item)
    .toList();

List<FeedCommentReadModel> withoutComment({
  required List<FeedCommentReadModel> comments,
  required String commentId,
}) => comments.where((item) => item.commentId != commentId).toList();
