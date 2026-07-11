import 'package:flutter/material.dart';

import '../../../you/presentation/widgets/you_surface_primitives.dart';
import '../../domain/models/feed_display_models.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_comment_sheet_models.dart';

part 'feed_comment_list.dart';
part 'feed_comment_sheet_layout.dart';
part 'feed_comment_sheet_source.dart';

class FeedCommentSheet extends StatefulWidget {
  const FeedCommentSheet._(this._source, [this.sheetController]);

  factory FeedCommentSheet.fromRepository(
    FeedPostReadModel post,
    FeedCommentsRepository repository,
    String? viewerUserId,
  ) => FeedCommentSheet._(
    _RepositoryFeedCommentSheetSource(post, repository, viewerUserId),
  );

  factory FeedCommentSheet.fromFallback(
    FeedPostReadModel post,
    String? viewerUserId,
    FeedCommentFallback fallback,
  ) => FeedCommentSheet._(
    _FallbackFeedCommentSheetSource(post, viewerUserId, fallback),
  );

  FeedCommentSheet controlledBy(DraggableScrollableController? controller) =>
      FeedCommentSheet._(_source, controller);

  final _FeedCommentSheetSource _source;
  final DraggableScrollableController? sheetController;

  @override
  State<FeedCommentSheet> createState() => _FeedCommentSheetState();
}

class _FeedCommentSheetState extends State<FeedCommentSheet> {
  final _controller = TextEditingController();
  late List<FeedCommentReadModel> _comments = sessionCommentModels(
    comments: widget._source.sessionComments,
    authorUserId: widget._source.viewerUserId ?? 'runner-current',
  );
  FeedCommentCursor? _nextCursor;
  var _isLoading = false, _isLoadingMore = false, _exhausted = false;
  var _source = FeedTimelineSource.server;
  String? _loadError, _validationError, _editingCommentId;
  var _isSubmitting = false;

  bool get _isOffline => _source == FeedTimelineSource.cachedOffline;
  bool get _canSubmit =>
      !_isOffline &&
      !_isLoading &&
      !_isSubmitting &&
      _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget._source.repository != null) {
      _loadInitial();
    } else {
      _exhausted = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final repository = widget._source.repository;
    if (repository == null) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final page = await repository.loadComments(
        postId: widget._source.post.postId,
      );
      if (!mounted) return;
      setState(() {
        _comments = page.comments;
        _source = page.source;
        _exhausted = page.exhausted;
        _nextCursor = lastCommentCursor(page.comments);
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Comments could not load.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    final repository = widget._source.repository;
    if (repository == null ||
        _nextCursor == null ||
        _exhausted ||
        _isLoading ||
        _isLoadingMore) {
      return;
    }
    setState(() => _isLoadingMore = true);
    try {
      final page = await repository.loadComments(
        postId: widget._source.post.postId,
        startAfter: _nextCursor,
      );
      if (!mounted) return;
      final ids = _comments.map((item) => item.commentId).toSet();
      setState(() {
        _comments = [
          ..._comments,
          ...page.comments.where((item) => ids.add(item.commentId)),
        ];
        _source = page.source;
        _exhausted = page.exhausted;
        _nextCursor = lastCommentCursor(page.comments);
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Comments could not load.');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _submit() async {
    if (!mounted) return;
    final body = _controller.text.trim();
    if (body.isEmpty || body.length > 500) {
      setState(() => _validationError = 'Write 1 to 500 characters.');
      return;
    }
    if (_isOffline || _isSubmitting) return;
    final repository = widget._source.repository;
    final editingId = _editingCommentId;
    setState(() => _isSubmitting = true);
    try {
      if (repository == null) {
        widget._source.onSubmitted?.call(body);
        setState(
          () => _comments = [
            FeedCommentReadModel(
              commentId: 'session-${_comments.length}',
              authorUserId: widget._source.viewerUserId ?? 'runner-current',
              authorDisplayName: 'You',
              authorAvatarInitials: 'YO',
              body: body,
              createdAt: DateTime.now(),
            ),
            ..._comments,
          ],
        );
      } else if (editingId == null) {
        await repository.createComment(
          FeedCommentMutation(
            postId: widget._source.post.postId,
            commentId: null,
            body: body,
          ),
        );
        await _loadInitial();
      } else {
        await repository.updateComment(
          FeedCommentMutation(
            postId: widget._source.post.postId,
            commentId: editingId,
            body: body,
          ),
        );
        if (mounted) {
          setState(
            () => _comments = replaceCommentBody(
              comments: _comments,
              commentId: editingId,
              body: body,
            ),
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _controller.clear();
        _editingCommentId = null;
        _validationError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _validationError = 'Comment could not save.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _beginEdit(FeedCommentReadModel comment) {
    _controller.text = comment.body;
    setState(() => _editingCommentId = comment.commentId);
  }

  void _clearValidationError() => setState(() => _validationError = null);

  Future<void> _confirmDelete(FeedCommentReadModel comment) async {
    if (!await confirmFeedCommentDelete(context) || _isOffline || _isSubmitting) {
      return;
    }
    try {
      setState(() => _isSubmitting = true);
      await widget._source.repository?.deleteComment(
        postId: widget._source.post.postId,
        commentId: comment.commentId,
      );
      if (mounted) {
        setState(() {
          _comments = withoutComment(
            comments: _comments,
            commentId: comment.commentId,
          );
          if (_editingCommentId == comment.commentId) {
            _editingCommentId = null;
            _controller.clear();
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _validationError = 'Comment could not delete.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => buildCommentSheetLayout(context);
}
