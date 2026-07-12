import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../data/static_feed_repository.dart';
import '../domain/models/feed_display_models.dart';
import '../domain/repositories/feed_repository.dart';
import 'current_session_feed_store.dart';
import 'feed_timeline_screen_controller.dart';
import 'widgets/feed_header.dart';
import 'widgets/feed_post_list.dart';

export 'current_session_feed_store.dart';

class CurrentSessionFeed extends StatefulWidget {
  const CurrentSessionFeed({
    this.repository = const StaticFeedRepository(),
    this.viewerContext,
    this.currentAuthorProfile,
    super.key,
  });

  final FeedRepository repository;
  final FeedViewerContext? viewerContext;
  final FeedAuthorProfileSnapshot? currentAuthorProfile;

  @override
  State<CurrentSessionFeed> createState() => _CurrentSessionFeedState();
}

class _CurrentSessionFeedState extends State<CurrentSessionFeed> {
  late FeedTimelineScreenController _controller;
  CurrentSessionFeedStore? _sessionStore;

  @override
  void initState() {
    super.initState();
    _replaceController();
  }

  @override
  void didUpdateWidget(covariant CurrentSessionFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.viewerContext != widget.viewerContext) {
      _controller.removeListener(_rebuild);
      _controller.dispose();
      _replaceController();
    } else if (oldWidget.currentAuthorProfile != widget.currentAuthorProfile) {
      _controller.updateCurrentAuthorProfile(widget.currentAuthorProfile);
      _syncAuthorProfile();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextStore = CurrentSessionFeedScope.maybeOf(context);
    if (_sessionStore == nextStore) return;
    _sessionStore?.removeListener(_onSessionChanged);
    _sessionStore = nextStore;
    _controller.attachSession(nextStore);
    _syncAuthorProfile();
    _sessionStore?.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _sessionStore?.removeListener(_onSessionChanged);
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  void _replaceController() {
    _controller = FeedTimelineScreenController(
      widget.repository,
      widget.viewerContext,
      widget.currentAuthorProfile,
    )..addListener(_rebuild);
    _controller.attachSession(_sessionStore);
    _controller.refresh();
  }

  void _syncAuthorProfile() {
    final profile = widget.currentAuthorProfile;
    if (profile != null) {
      _sessionStore?.updateAuthorProfile(profile);
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onSessionChanged() {
    if (_controller.clearForOwnerChange() && _controller.commentSheetOpen) {
      Navigator.of(context).pop();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: RuniacColors.background,
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FeedHeader(),
          ),
          Expanded(
            child: RefreshIndicator(
              semanticsLabel: 'Pull to refresh feed',
              onRefresh: _controller.refresh,
              child: FeedPostList(controller: _controller),
            ),
          ),
        ],
      ),
    ),
  );
}
