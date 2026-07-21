import 'feed_data_port.dart';

/// Session-scoped cache that overlays live author levels onto Feed posts and
/// comments.
///
/// Each post and comment stores an `authorLevelLabel` frozen at publish
/// time, which can go stale or be entirely absent on older content. This
/// resolver asks [FeedDataPort.fetchAuthorLevels] for the author's CURRENT
/// level and caches it for the life of one Feed session. It never computes
/// a level itself — it only transports whatever the backend already
/// returned.
///
/// Any failure (offline, permission denial, a callable that isn't deployed
/// yet) is swallowed entirely: nothing is cached for that attempt, and every
/// caller keeps using the stored, possibly-stale label. The Feed must always
/// be able to paint even if this resolver never resolves anything.
class FeedAuthorLevelResolver {
  FeedAuthorLevelResolver(this._port);

  final FeedDataPort _port;
  final Map<String, FeedAuthorLevel> _cache = <String, FeedAuthorLevel>{};

  /// The cached live level for [uid], or `null` if none has been resolved.
  FeedAuthorLevel? lookup(String uid) => _cache[uid];

  FeedAuthorLevel? operator [](String uid) => lookup(uid);

  /// Fetches and caches live levels for every uid in [uids] not already
  /// cached. Swallows every error from the port so callers can always fall
  /// back to a post or comment's stored `authorLevelLabel`.
  Future<void> ensureResolved(Iterable<String> uids) async {
    final missing = <String>{
      for (final uid in uids)
        if (!_cache.containsKey(uid)) uid,
    };
    if (missing.isEmpty) return;
    try {
      final resolved = await _port.fetchAuthorLevels(
        missing.toList(growable: false),
      );
      _cache.addAll(resolved);
    } catch (_) {
      // Offline, permission-denied, or a not-yet-deployed callable: leave
      // the cache untouched so every caller falls back to the stored label.
    }
  }

  /// Clears every cached level. Called on pull-to-refresh so a fresh Feed
  /// load re-resolves rather than reusing a stale session cache.
  void invalidate() => _cache.clear();
}
