import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/assets/runiac_assets.dart';
import '../../../core/theme/runiac_colors.dart';
import '../data/static_leaderboard_repository.dart';
import '../domain/models/leaderboard_league_catalog.dart';
import '../domain/models/leaderboard_read_model.dart';
import '../domain/repositories/leaderboard_repository.dart';
import 'data/leaderboard_demo_snapshots.dart';
import 'leaderboard_read_model_display_adapter.dart';
import 'models/leaderboard_display_models.dart';
import 'widgets/leaderboard_detail_screen.dart';
import 'widgets/leaderboard_dialogs.dart';
import 'widgets/leaderboard_map_background.dart';
import 'widgets/leaderboard_region_preview_sheet.dart';
import 'widgets/leaderboard_top_overlay.dart';
import 'widgets/runner_achievement_profile_screen.dart';
import 'widgets/share_rank_floating_panel.dart';

export 'widgets/runner_achievement_profile_screen.dart'
    show resolveRunnerMetricValueFontSize;

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({
    super.key,
    this.repository = const StaticLeaderboardRepository(),
    this.clock = _systemClock,
  });

  final LeaderboardRepository repository;
  final DateTime Function() clock;

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

DateTime _systemClock() => DateTime.timestamp().toLocal();

class _LeaderboardTabState extends State<LeaderboardTab> {
  static const double _userRegionExpandedSheetHeight = 464;
  static const double _regionalExpandedSheetHeight = 374;
  static const double _collapsedSheetHeight = 46;
  static const _expiredRetryDelays = [
    Duration.zero,
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  double _sheetProgress = 1;
  bool _showingDetail = false;
  bool _loading = true;
  Object? _loadError;
  LeaderboardReadModel? _readModel;
  LeaderboardDetailDisplaySnapshot? _selectedRegion;
  RunnerAchievementProfileSnapshot? _selectedProfile;
  Timer? _periodRefreshTimer;
  var _expiredRetryAttempt = 0;
  var _loadSerial = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLeaderboard());
  }

  @override
  void didUpdateWidget(covariant LeaderboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.clock != widget.clock) {
      _expiredRetryAttempt = 0;
      unawaited(_loadLeaderboard());
    }
  }

  @override
  void dispose() {
    _periodRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    final loadSerial = ++_loadSerial;
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final leaderboard = await widget.repository.loadLeaderboard();
      if (!mounted || loadSerial != _loadSerial) {
        return;
      }
      setState(() {
        _readModel = leaderboard;
        _selectedRegion =
            leaderboard.status == LeaderboardReadStatus.regionRequired
            ? null
            : leaderboardDisplaySnapshotFromReadModel(
                leaderboard,
                widget.clock(),
              );
        _loading = false;
      });
      _schedulePeriodRefresh(leaderboard.periodEndsAt);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac leaderboard',
          context: ErrorDescription('loading leaderboard read model'),
        ),
      );
      if (!mounted || loadSerial != _loadSerial) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  Future<void> _selectRegion(String regionId) async {
    final loadSerial = ++_loadSerial;
    setState(() {
      _loading = true;
      _loadError = null;
      _sheetProgress = 1;
    });
    try {
      final leaderboard = await widget.repository.loadRegion(
        regionId: regionId,
      );
      if (!mounted || loadSerial != _loadSerial) {
        return;
      }
      setState(() {
        _readModel = leaderboard;
        _selectedRegion = leaderboardDisplaySnapshotFromReadModel(
          leaderboard,
          widget.clock(),
        );
        _loading = false;
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac leaderboard',
          context: ErrorDescription('loading selected Leaderboard region'),
        ),
      );
      if (!mounted || loadSerial != _loadSerial) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  void _schedulePeriodRefresh(DateTime? periodEndsAt) {
    _periodRefreshTimer?.cancel();
    if (periodEndsAt == null) {
      return;
    }
    final remaining = periodEndsAt.difference(widget.clock());
    if (!remaining.isNegative && remaining > Duration.zero) {
      _expiredRetryAttempt = 0;
      _periodRefreshTimer = Timer(remaining, _loadLeaderboard);
      return;
    }
    if (_expiredRetryAttempt >= _expiredRetryDelays.length) {
      return;
    }
    final delay = _expiredRetryDelays[_expiredRetryAttempt];
    _expiredRetryAttempt += 1;
    if (delay == Duration.zero) {
      scheduleMicrotask(_loadLeaderboard);
    } else {
      _periodRefreshTimer = Timer(delay, _loadLeaderboard);
    }
  }

  void _openDetail() {
    if (_selectedRegion == null) {
      return;
    }
    setState(() {
      _showingDetail = true;
    });
  }

  void _closeDetail() {
    setState(() {
      _showingDetail = false;
      _selectedProfile = null;
    });
  }

  void _openRunnerProfile(RunnerAchievementProfileSnapshot profile) {
    setState(() {
      _selectedProfile = profile;
    });
  }

  void _openShareRankPanel() {
    final snapshot = _selectedRegion;
    final currentUserRow = snapshot?.nearbyRanks
        .where((row) => row.isCurrentUser)
        .firstOrNull;
    if (snapshot == null || currentUserRow == null) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: RuniacColors.textPrimary.withValues(alpha: 0.48),
      builder: (context) {
        return ShareRankFloatingPanel(
          regionName: snapshot.regionName,
          divisionName: snapshot.divisionLabel,
          rankLabel: currentUserRow.rankLabel,
        );
      },
    );
  }

  void _closeRunnerProfile() {
    setState(() {
      _selectedProfile = null;
    });
  }

  void _handleSheetDragUpdate(DragUpdateDetails details) {
    final expandedSheetHeight = _expandedSheetHeight;
    setState(() {
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy /
                      (expandedSheetHeight - _collapsedSheetHeight))
              .clamp(0, 1);
    });
  }

  void _handleSheetDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    setState(() {
      if (velocity > 260) {
        _sheetProgress = 0;
      } else if (velocity < -260) {
        _sheetProgress = 1;
      } else {
        _sheetProgress = _sheetProgress >= 0.5 ? 1 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedProfile = _selectedProfile;
    if (selectedProfile != null) {
      return RunnerAchievementProfileScreen(
        profile: selectedProfile,
        onBack: _closeRunnerProfile,
      );
    }
    final snapshot = _selectedRegion;
    if (_showingDetail && snapshot != null) {
      return LeaderboardDetailScreen(
        snapshot: snapshot,
        onBack: _closeDetail,
        onProfileSelected: _openRunnerProfile,
      );
    }
    final readModel = _readModel;
    if (readModel?.status == LeaderboardReadStatus.regionRequired) {
      return _LeaderboardStateMessage(
        key: const Key('leaderboard_region_required_state'),
        message:
            'Choose your planning area in Profile to join the monthly leaderboard.',
        actionLabel: 'Retry',
        onAction: _loadLeaderboard,
      );
    }
    if (snapshot == null) {
      return _LeaderboardStateMessage(
        key: const Key('leaderboard_initial_state'),
        message: _loadError == null
            ? 'Loading monthly leaderboard…'
            : 'Leaderboard could not be loaded.',
        actionLabel: _loadError == null ? null : 'Retry',
        onAction: _loadError == null ? null : _loadLeaderboard,
        loading: _loading && _loadError == null,
      );
    }
    final expandedSheetHeight = _expandedSheetHeight;
    final hiddenSheetHeight =
        (expandedSheetHeight - _collapsedSheetHeight) * (1 - _sheetProgress);
    final league =
        leaderboardLeagueForKey(readModel?.divisionKey ?? '') ??
        leaderboardLeagueDefinitions.first;
    final mapRegions = leaderboardMapRegionsForHomeRegion(
      readModel?.homeRegionId ?? '',
    );

    return ColoredBox(
      color: const Color(0xFFEAE6DD),
      child: Stack(
        children: [
          Positioned.fill(
            child: LeaderboardMapBackground(
              regions: mapRegions,
              selectedRegionId: snapshot.regionId,
              onRegionSelected: _selectRegion,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 14),
              child: LeaderboardTopOverlay(
                divisionName: league.name,
                levelRange: league.levelRangeLabel,
                assetPath: _leagueAssetPath(league.key),
                onShowLeagues: () => showLeaderboardLeaguesDialog(context),
                onShowTips: () => showLeaderboardTipsDialog(context),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: -hiddenSheetHeight,
            child: LeaderboardRegionPreviewSheet(
              height: expandedSheetHeight,
              snapshot: snapshot,
              onVerticalDragUpdate: _handleSheetDragUpdate,
              onVerticalDragEnd: _handleSheetDragEnd,
              onViewMoreRanking: _openDetail,
              onShareMyRank: _openShareRankPanel,
              onProfileSelected: _openRunnerProfile,
            ),
          ),
          if (_loading)
            const Positioned(
              right: 18,
              top: 84,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          if (_loadError != null)
            Positioned(
              left: 16,
              right: 16,
              top: 82,
              child: Material(
                color: RuniacColors.white,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: const Text('Leaderboard could not be refreshed.'),
                  trailing: TextButton(
                    onPressed: _loadLeaderboard,
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _expandedSheetHeight {
    return _selectedRegion?.isUserRegion == true
        ? _userRegionExpandedSheetHeight
        : _regionalExpandedSheetHeight;
  }
}

class _LeaderboardStateMessage extends StatelessWidget {
  const _LeaderboardStateMessage({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 18),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _leagueAssetPath(String key) {
  return switch (key) {
    'tier_01' => RuniacAssets.leaderboardLeagueIron,
    'tier_02' => RuniacAssets.leaderboardLeagueBronze,
    'tier_03' => RuniacAssets.leaderboardLeagueSilver,
    'tier_04' => RuniacAssets.leaderboardLeagueGold,
    'tier_05' => RuniacAssets.leaderboardLeaguePlatinum,
    'tier_06' => RuniacAssets.leaderboardLeagueEmerald,
    'tier_07' => RuniacAssets.leaderboardLeagueDiamond,
    'tier_08' => RuniacAssets.leaderboardLeagueMaster,
    'tier_09' => RuniacAssets.leaderboardLeagueGrandmaster,
    'tier_10' => RuniacAssets.leaderboardLeagueChallenger,
    _ => RuniacAssets.leaderboardLeagueIron,
  };
}
