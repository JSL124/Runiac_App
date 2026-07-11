import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:runiac_app/core/theme/runiac_colors.dart';
import 'package:runiac_app/core/widgets/runiac_back_header.dart';

import 'advanced_analysis_screen.dart';
import '../domain/models/advanced_analysis_snapshot.dart';
import '../domain/models/complete_run_result.dart';
import '../domain/models/local_run_completion_payload.dart';
import '../domain/models/coaching_summary_snapshot.dart';
import '../domain/models/pace_graph_snapshot.dart';
import '../domain/models/run_location_sample.dart';
import '../domain/models/run_route_snapshot.dart';
import '../domain/models/run_summary_snapshot.dart';
import '../domain/services/advanced_analysis_snapshot_builder.dart';
import '../../feed/data/feed_publish/feed_publish_service.dart';
import '../../feed/data/feed_publish/feed_thumbnail_artifact.dart';
import '../../feed/data/feed_publish/feed_thumbnail_capture.dart';
import '../../feed/data/feed_publish/history_artifact_resolver.dart';
import '../../feed/data/feed_publish/firebase_feed_publish_gateway.dart';
import '../../you/presentation/widgets/activity_route_preview.dart';
import '../../you/presentation/current_session_activity_history.dart';
import 'run_repository_scope.dart';
import 'data/run_completion_demo_snapshots.dart';
import 'widgets/completed_route_map_surface.dart';
import 'widgets/advanced_analysis/advanced_analysis_splits_table.dart';
import 'widgets/share_achievement_sheet.dart';
import 'widgets/share_route_to_feed_sheet.dart';
import 'xp_update_screen.dart';

const _rBlue = Color(0xFF2F51C8);
const _rOrange = Color(0xFFFB6414);
const _rWhite = Color(0xFFFFFFFF);
const _rBlue90 = Color(0xE62F51C8);
const _rBlue75 = Color(0xBF2F51C8);
const _rBlue60 = Color(0x992F51C8);
const _rBlue45 = Color(0x732F51C8);
const _rBlue30 = Color(0x4D2F51C8);
const _rBlue18 = Color(0x2E2F51C8);
const _rBlue10 = Color(0x1A2F51C8);
const _rBlue06 = Color(0x0F2F51C8);
const _cardRadius = 20.0;
const _paceChartYAxisWidth = 38.0;
const _paceChartAxisGap = 4.0;
const _paceChartHorizontalPlotInset = 16.0;
const _paceChartXAxisLabelWidth = 32.0;

@visibleForTesting
double paceChartDisplayProgressForPoint({
  required int index,
  required int pointCount,
  required double rawProgressFraction,
}) {
  if (pointCount <= 1 || index <= 0) {
    return 0;
  }
  if (index >= pointCount - 1) {
    return 1;
  }
  return rawProgressFraction.clamp(0.0, 1.0);
}

class ViewSummaryScreen extends StatelessWidget {
  const ViewSummaryScreen({
    super.key,
    this.summary = defaultRunSummarySnapshot,
    this.completionResult,
    this.completionPayload,
    this.showXpUpdateAction = true,
    this.showLowDataSaveAction = true,
    this.mapboxAccessToken,
    this.mapboxBuilder,
    this.feedPublishService,
    this.historyArtifactResolver,
  });

  final RunSummarySnapshot summary;
  final CompleteRunResult? completionResult;
  final LocalRunCompletionPayload? completionPayload;
  final bool showXpUpdateAction;
  final bool showLowDataSaveAction;
  final String? mapboxAccessToken;
  final CompletedRouteMapboxBuilder? mapboxBuilder;
  final FeedPublishService? feedPublishService;
  final HistoryArtifactResolver? historyArtifactResolver;

  void _showSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showShareRouteToFeed(
    BuildContext context,
    RunSummarySnapshot summary,
  ) async {
    final artifact = await _resolveHistoryArtifact(context, summary);
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (sheetContext) => ShareRouteToFeedSheet(
        summary: summary,
        artifact: artifact,
        onCancel: () => Navigator.of(sheetContext).pop(),
        onConfirm: () async {
          final activityId = completionResult?.activityId;
          if (activityId == null || activityId.isEmpty || artifact == null) {
            throw StateError('This run is not ready to post yet.');
          }
          await (feedPublishService ??
                  FeedPublishService(gateway: FirebaseFeedPublishGateway()))
              .publishAfterConfirmation(
                activityId: activityId,
                artifact: artifact,
              );
          if (context.mounted) {
            _showSoonMessage(context, 'Route shared to Feed.');
          }
        },
      ),
    );
  }

  Future<FeedThumbnailArtifact?> _resolveHistoryArtifact(
    BuildContext context,
    RunSummarySnapshot summary,
  ) async {
    final activityId = completionResult?.activityId;
    if (activityId == null || activityId.isEmpty) return null;
    final cacheIdentity = completionResult?.clientRunSessionId;
    final request = ActivityRouteThumbnailRequest(
      route: summary.route,
      logicalSize: const Size(88, 88),
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      allowExternalStaticMap: true,
      isDemoRoute: false,
      isCurrentSessionRoute: true,
      activityId: cacheIdentity == null || cacheIdentity.isEmpty
          ? activityId
          : cacheIdentity,
    );
    try {
      return await (historyArtifactResolver ??
              CacheOnlyHistoryArtifactResolver())
          .resolve(request);
    } on FeedThumbnailCaptureException {
      return null;
    }
  }

  Future<void> _goHomeFromSummary(
    BuildContext context, {
    required bool hasSufficientData,
  }) async {
    if (!hasSufficientData) {
      final decision = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.48),
        builder: (context) => const _LowDataSaveDecisionSheet(),
      );
      if (!context.mounted || decision == null) {
        return;
      }
      if (decision) {
        final result = completionResult;
        final payload = completionPayload;
        if (result != null && payload != null) {
          final store = CurrentSessionActivityHistoryScope.maybeOf(context);
          final savePayload = payload.copyWith(userConfirmedLowDataSave: true);
          try {
            await store?.saveCompletedRun(result, payload: savePayload);
          } catch (error, stackTrace) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'runiac run summary',
                context: ErrorDescription('saving a low-data run locally'),
              ),
            );
            return;
          }
          if (!context.mounted) {
            return;
          }
          if (store != null) {
            unawaited(
              store
                  .syncPendingRuns(RunRepositoryScope.of(context))
                  .catchError(
                    (Object error, StackTrace stackTrace) =>
                        FlutterError.reportError(
                          FlutterErrorDetails(
                            exception: error,
                            stack: stackTrace,
                            library: 'runiac run summary',
                            context: ErrorDescription(
                              'syncing a saved low-data run',
                            ),
                          ),
                        ),
                  ),
            );
          }
        }
      }
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final displayedSummary = completionResult?.summary ?? summary;
    final hasSufficientData = displayedSummary.hasSufficientData;
    final analysisSnapshot = const AdvancedAnalysisSnapshotBuilder()
        .fromRunSummary(displayedSummary);

    return Scaffold(
      backgroundColor: _rWhite,
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                RuniacBackHeader(
                  title: displayedSummary.title,
                  subtitle: displayedSummary.dateTimeLabel,
                  tooltip: 'Back to cool down',
                  onBack: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  titleStyle: const TextStyle(
                    color: _rBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                  subtitleStyle: const TextStyle(
                    color: _rBlue60,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                  trailing: IconButton(
                    tooltip: 'Share summary',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withValues(alpha: 0.48),
                        builder: (context) => const ShareAchievementSheet(),
                      );
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: _rBlue,
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const _NoOverscrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SourceLabel(
                            sourceLabel: displayedSummary.sourceLabel,
                          ),
                          _MapPreview(
                            routeName: displayedSummary.routeName,
                            route: displayedSummary.route,
                            mapboxAccessToken: mapboxAccessToken,
                            mapboxBuilder: mapboxBuilder,
                          ),
                          _HeroDistance(
                            distanceKm: displayedSummary.distanceKm,
                          ),
                          _MetricSummary(summary: displayedSummary),
                          _PaceSection(
                            hasSufficientData: hasSufficientData,
                            paceGraph: displayedSummary.paceGraph,
                          ),
                          _AnalysisSection(
                            hasSufficientData: hasSufficientData,
                            paceAnalysis: analysisSnapshot.pace,
                            onMoreDetails: () {
                              if (!hasSufficientData) {
                                _showSoonMessage(
                                  context,
                                  'Run a little longer to unlock analysis.',
                                );
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => AdvancedAnalysisScreen(
                                    title: displayedSummary.title,
                                    subtitle: displayedSummary.dateTimeLabel,
                                    analysisSnapshot: analysisSnapshot,
                                  ),
                                ),
                              );
                            },
                          ),
                          _CoachingSection(
                            coachingSummary: displayedSummary.coachingSummary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _BottomActions(
                  hasSufficientData: hasSufficientData,
                  showXpUpdateAction: showXpUpdateAction,
                  showLowDataSaveAction: showLowDataSaveAction,
                  onShareRoute: () {
                    _showShareRouteToFeed(context, displayedSummary);
                  },
                  onXpUpdate: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => XpUpdateScreen(
                          model:
                              completionResult?.xpUpdate ??
                              defaultXpUpdateDisplayModel,
                        ),
                      ),
                    );
                  },
                  onGoHome: () {
                    _goHomeFromSummary(
                      context,
                      hasSufficientData: hasSufficientData,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LowDataSaveDecisionSheet extends StatelessWidget {
  const _LowDataSaveDecisionSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _rWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _rBlue18,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Save this short run?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This run has limited data, so it may not be useful for analysis. You can still keep it in your running history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rBlue60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _rBlue,
                    side: const BorderSide(color: _rBlue30, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Discard'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _rBlue,
                    foregroundColor: _rWhite,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    elevation: 8,
                    shadowColor: const Color(0x382F51C8),
                  ),
                  child: const Text('Save run'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoOverscrollBehavior extends ScrollBehavior {
  const _NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class _SourceLabel extends StatelessWidget {
  const _SourceLabel({required this.sourceLabel});

  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        sourceLabel,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _rBlue60,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.routeName,
    required this.route,
    this.mapboxAccessToken,
    this.mapboxBuilder,
  });

  final String routeName;
  final RunRouteSnapshot route;
  final String? mapboxAccessToken;
  final CompletedRouteMapboxBuilder? mapboxBuilder;

  @override
  Widget build(BuildContext context) {
    final canOpenExpanded = route.hasRoute || route.hasLocation;
    final preview = _MapPreviewFrame(
      child: CompletedRouteMapSurface(
        route: route,
        mapboxAccessToken: mapboxAccessToken,
        mapboxBuilder: mapboxBuilder,
        fallback: _StaticMapPreview(route: route),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          preview,
          if (canOpenExpanded)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('summary_route_preview_tap_target'),
                  borderRadius: BorderRadius.circular(_cardRadius),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (context) => _ExpandedRouteMapScreen(
                          routeName: routeName,
                          route: route,
                          mapboxAccessToken: mapboxAccessToken,
                          mapboxBuilder: mapboxBuilder,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPreviewFrame extends StatelessWidget {
  const _MapPreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: _rBlue10),
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        child: Stack(
          children: [
            SizedBox(height: 184, child: child),
            const Positioned.fill(child: _MapFade()),
          ],
        ),
      ),
    );
  }
}

class _StaticMapPreview extends StatelessWidget {
  const _StaticMapPreview({required this.route});

  final RunRouteSnapshot route;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: Key(_mapPreviewKeyFor(route)),
      painter: _MapPreviewPainter(route: route),
      child: const SizedBox.expand(),
    );
  }
}

class _ExpandedRouteMapScreen extends StatelessWidget {
  const _ExpandedRouteMapScreen({
    required this.routeName,
    required this.route,
    this.mapboxAccessToken,
    this.mapboxBuilder,
  });

  final String routeName;
  final RunRouteSnapshot route;
  final String? mapboxAccessToken;
  final CompletedRouteMapboxBuilder? mapboxBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('summary_route_expanded_screen'),
      backgroundColor: _rWhite,
      body: Stack(
        children: [
          Positioned.fill(
            child: CompletedRouteMapSurface(
              route: route,
              mapboxAccessToken: mapboxAccessToken,
              mapboxBuilder: mapboxBuilder,
              isExpanded: true,
              fallback: _ExpandedStaticRouteMap(route: route),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        routeName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _rBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: _rWhite,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x242F51C8),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        key: const Key('summary_route_expanded_close'),
                        tooltip: 'Close route map',
                        onPressed: () => Navigator.of(context).pop(),
                        color: _rBlue,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedStaticRouteMap extends StatelessWidget {
  const _ExpandedStaticRouteMap({required this.route});

  final RunRouteSnapshot route;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: Key('${_mapPreviewKeyFor(route)}_expanded'),
      painter: _MapPreviewPainter(route: route),
      child: const SizedBox.expand(),
    );
  }
}

String _mapPreviewKeyFor(RunRouteSnapshot route) {
  if (route.hasRoute) {
    return 'summary_route_preview_route';
  }
  if (route.hasLocation) {
    return 'summary_route_preview_dot';
  }
  return 'summary_route_preview_placeholder';
}

class _MapFade extends StatelessWidget {
  const _MapFade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00F8FAFF), Color(0x8CF8FAFF)],
          stops: [0.6, 1],
        ),
      ),
    );
  }
}

class _HeroDistance extends StatelessWidget {
  const _HeroDistance({required this.distanceKm});

  final String distanceKm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              distanceKm,
              style: const TextStyle(
                color: _rBlue,
                fontSize: 72,
                fontWeight: FontWeight.w800,
                letterSpacing: -2.8,
                height: 0.95,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'km',
              style: TextStyle(
                color: _rBlue75,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricSummary extends StatelessWidget {
  const _MetricSummary({required this.summary});

  final RunSummarySnapshot summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 18, 34, 0),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricText(
                      value: summary.avgPace,
                      label: 'Avg Pace',
                    ),
                  ),
                  Expanded(
                    child: _MetricText(value: summary.duration, label: 'Time'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MetricText(
                      value: _metricValueWithUnit(summary.avgHeartRate, 'bpm'),
                      label: 'Avg Heart Rate',
                    ),
                  ),
                  Expanded(
                    child: _MetricText(
                      value: _metricValueWithUnit(summary.calories, 'kcal'),
                      label: 'Est. calories',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _metricValueWithUnit(String value, String unit) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == '--') {
    return '--';
  }
  return '$normalized $unit';
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rBlue,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _rBlue60,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _PaceSection extends StatelessWidget {
  const _PaceSection({
    required this.hasSufficientData,
    required this.paceGraph,
  });

  final bool hasSufficientData;
  final PaceGraphSnapshot paceGraph;

  @override
  Widget build(BuildContext context) {
    final showGuard = !hasSufficientData || !paceGraph.isAvailable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(title: 'Pace Over Time'),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: _GuardedAnalysisPreview(
              showGuard: showGuard,
              clipContent: false,
              child: _PaceChart(graph: paceGraph),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaceChart extends StatelessWidget {
  const _PaceChart({required this.graph});

  final PaceGraphSnapshot graph;

  @override
  Widget build(BuildContext context) {
    final renderedGraph = graph.isAvailable ? graph : _lockedPaceGraphPreview;
    final isLockedPreview = !graph.isAvailable;
    final yAxisLabels = isLockedPreview
        ? _lockedPaceGraphPreview.yAxisLabels
        : graph.yAxisLabels;
    final xAxisLabels = isLockedPreview
        ? _lockedPaceGraphPreview.xAxisLabels
        : graph.xAxisLabels;

    return Column(
      children: [
        SizedBox(
          height: 96,
          child: Row(
            children: [
              SizedBox(
                width: _paceChartYAxisWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yAxisLabels
                      .map((label) => _YAxisLabel(label))
                      .toList(),
                ),
              ),
              const SizedBox(width: _paceChartAxisGap),
              Expanded(
                child: CustomPaint(
                  painter: _PaceChartPainter(
                    graph: renderedGraph,
                    isLockedPreview: isLockedPreview,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: _paceChartYAxisWidth),
            const SizedBox(width: _paceChartAxisGap),
            Expanded(child: _PaceXAxisLabels(labels: xAxisLabels)),
          ],
        ),
      ],
    );
  }
}

const _lockedPaceGraphPreview = PaceGraphSnapshot(
  isAvailable: true,
  points: [
    PaceGraphPoint(
      elapsedSeconds: 0,
      progressFraction: 0,
      paceSecondsPerKm: 500,
    ),
    PaceGraphPoint(
      elapsedSeconds: 300,
      progressFraction: 0.24,
      paceSecondsPerKm: 472,
    ),
    PaceGraphPoint(
      elapsedSeconds: 600,
      progressFraction: 0.5,
      paceSecondsPerKm: 486,
    ),
    PaceGraphPoint(
      elapsedSeconds: 900,
      progressFraction: 0.76,
      paceSecondsPerKm: 448,
    ),
    PaceGraphPoint(
      elapsedSeconds: 1200,
      progressFraction: 1,
      paceSecondsPerKm: 460,
    ),
  ],
  yAxisLabels: ['6:00', '7:00', '8:00'],
  xAxisLabels: ['0:00', '5:00', '10:00'],
  paceRangeMinSecondsPerKm: 420,
  paceRangeMaxSecondsPerKm: 520,
);

class _PaceXAxisLabels extends StatelessWidget {
  const _PaceXAxisLabels({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (labels.isEmpty) {
            return const SizedBox.shrink();
          }

          final availableWidth = constraints.maxWidth;
          final horizontalInset =
              availableWidth > (_paceChartHorizontalPlotInset * 2)
              ? _paceChartHorizontalPlotInset
              : 0.0;
          final plotLeft = horizontalInset;
          final plotRight = availableWidth - horizontalInset;
          final plotWidth = (plotRight - plotLeft).clamp(0.0, double.infinity);
          final divisor = labels.length == 1 ? 1 : labels.length - 1;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < labels.length; index += 1)
                Positioned(
                  key: ValueKey('pace_x_axis_label_$index'),
                  left:
                      (plotLeft +
                              (plotWidth * (index / divisor)) -
                              (_paceChartXAxisLabelWidth / 2))
                          .clamp(
                            0.0,
                            (availableWidth - _paceChartXAxisLabelWidth).clamp(
                              0.0,
                              double.infinity,
                            ),
                          )
                          .toDouble(),
                  width: _paceChartXAxisLabelWidth,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _AxisLabel(labels[index]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      style: const TextStyle(
        color: _rBlue45,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        height: 0.95,
      ),
    );
  }
}

class _YAxisLabel extends StatelessWidget {
  const _YAxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _paceChartYAxisWidth,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: _AxisLabel(text),
        ),
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({
    required this.hasSufficientData,
    required this.paceAnalysis,
    required this.onMoreDetails,
  });

  final bool hasSufficientData;
  final AdvancedAnalysisPaceAnalysis paceAnalysis;
  final VoidCallback onMoreDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel(title: 'Splits'),
          const _AnalysisDivider(),
          const SizedBox(height: 14),
          _GuardedAnalysisPreview(
            showGuard: !hasSufficientData,
            clipContent: false,
            minHeight: hasSufficientData ? 0 : 96,
            child: AdvancedAnalysisSplitTable(analysis: paceAnalysis),
          ),
          const SizedBox(height: 12),
          const _AnalysisDivider(),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onMoreDetails,
            style: OutlinedButton.styleFrom(
              foregroundColor: _rBlue,
              side: const BorderSide(color: _rBlue18, width: 1.5),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            child: const Text('More Details'),
          ),
        ],
      ),
    );
  }
}

class _AnalysisDivider extends StatelessWidget {
  const _AnalysisDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: _rBlue10, height: 17, thickness: 1);
  }
}

class _GuardedAnalysisPreview extends StatelessWidget {
  const _GuardedAnalysisPreview({
    required this.showGuard,
    required this.child,
    this.clipContent = true,
    this.minHeight = 0,
  });

  final bool showGuard;
  final Widget child;
  final bool clipContent;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final preview = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          if (showGuard) const Positioned.fill(child: _LowDataGraphGuard()),
        ],
      ),
    );
    if (!clipContent) {
      return preview;
    }
    return ClipRRect(borderRadius: BorderRadius.circular(14), child: preview);
  }
}

class _LowDataGraphGuard extends StatelessWidget {
  const _LowDataGraphGuard();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
        child: DecoratedBox(
          decoration: BoxDecoration(color: _rWhite.withValues(alpha: 0.44)),
          child: Center(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More run data needed',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _rOrange,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: _rWhite, blurRadius: 10),
                        Shadow(
                          color: _rWhite,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pace insights will appear after a longer run.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _rOrange,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      shadows: [
                        Shadow(color: _rWhite, blurRadius: 10),
                        Shadow(
                          color: _rWhite,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachingSection extends StatelessWidget {
  const _CoachingSection({required this.coachingSummary});

  final CoachingSummarySnapshot coachingSummary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(title: coachingSummary.sectionTitle),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coachingSummary.headline,
                  style: const TextStyle(
                    color: _rBlue,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  coachingSummary.message,
                  style: const TextStyle(
                    color: _rBlue90,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    letterSpacing: -0.1,
                  ),
                ),
                if (coachingSummary.bullets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final bullet in coachingSummary.bullets)
                    _CoachingBullet(text: bullet),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: _rBlue10),
                const SizedBox(height: 14),
                _NextActionBlock(text: coachingSummary.nextAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachingBullet extends StatelessWidget {
  const _CoachingBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _rOrange,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const SizedBox(width: 5, height: 5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _rBlue75,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionBlock extends StatelessWidget {
  const _NextActionBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Focus',
          style: TextStyle(
            color: _rBlue,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(
            color: _rBlue75,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.hasSufficientData,
    required this.showXpUpdateAction,
    required this.showLowDataSaveAction,
    required this.onShareRoute,
    required this.onXpUpdate,
    required this.onGoHome,
  });

  final bool hasSufficientData;
  final bool showXpUpdateAction;
  final bool showLowDataSaveAction;
  final VoidCallback onShareRoute;
  final VoidCallback onXpUpdate;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    if (!hasSufficientData && !showLowDataSaveAction) {
      return const SizedBox.shrink();
    }

    if (!hasSufficientData) {
      return _BottomActionBar(
        child: FilledButton.icon(
          onPressed: onGoHome,
          icon: const Icon(Icons.home_rounded, size: 19),
          label: const Text('Go to Home'),
          style: FilledButton.styleFrom(
            backgroundColor: _rBlue,
            foregroundColor: _rWhite,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
            elevation: 8,
            shadowColor: const Color(0x382F51C8),
          ),
        ),
      );
    }

    return _BottomActionBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onShareRoute,
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share Route'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _rBlue,
              side: const BorderSide(color: _rBlue30, width: 1.5),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (showXpUpdateAction) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onXpUpdate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 19),
              label: const Text('View XP Update'),
              style: FilledButton.styleFrom(
                backgroundColor: _rOrange,
                foregroundColor: _rWhite,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                elevation: 8,
                shadowColor: const Color(0x4DFB6414),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
      decoration: const BoxDecoration(
        color: _rWhite,
        border: Border(top: BorderSide(color: _rBlue10)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: _rBlue,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _rWhite,
        border: Border.all(color: RuniacColors.cardBorder),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  const _MapPreviewPainter({required this.route});

  final RunRouteSnapshot route;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _rBlue06);
    canvas.save();
    canvas.scale(size.width / 360, size.height / 240);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 360, 240));

    final gridPaint = Paint()
      ..color = _rBlue10
      ..strokeWidth = 1;
    for (var x = 0.0; x <= 360; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, 240), gridPaint);
    }
    for (var y = 0.0; y <= 240; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(360, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = _rBlue18
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-20, 40), const Offset(380, 240), roadPaint);
    canvas.drawLine(const Offset(-20, 200), const Offset(380, 40), roadPaint);
    canvas.drawLine(const Offset(120, -20), const Offset(240, 260), roadPaint);

    final riverPath = Path()
      ..moveTo(-20, 130)
      ..cubicTo(60, 100, 140, 170, 220, 130)
      ..cubicTo(280, 100, 340, 100, 380, 130);
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = _rBlue10
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );

    if (route.hasRoute) {
      _drawCompletedRoute(canvas, const Size(360, 240));
    } else if (route.hasLocation) {
      _drawLocationDot(canvas, const Offset(180, 120));
    }

    canvas.restore();
  }

  void _drawCompletedRoute(Canvas canvas, Size size) {
    final transform = _SummaryRouteTransform.fromSegments(route.segments, size);
    if (transform == null) {
      return;
    }

    final shadowPaint = Paint()
      ..color = const Color(0x66304BB7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final routePaint = Paint()
      ..color = _rOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset? startPoint;
    Offset? endPoint;
    for (final segment in route.segments.where(
      (segment) => segment.length > 1,
    )) {
      final path = Path();
      for (var index = 0; index < segment.length; index += 1) {
        final point = transform.offsetFor(segment[index]);
        startPoint ??= point;
        endPoint = point;
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, routePaint);
    }

    if (startPoint != null) {
      canvas.drawCircle(startPoint, 7, Paint()..color = _rBlue);
      canvas.drawCircle(startPoint, 3, Paint()..color = _rWhite);
    }
    if (endPoint != null) {
      _drawLocationDot(canvas, endPoint);
    }
  }

  void _drawLocationDot(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 15, Paint()..color = const Color(0x33FB6414));
    canvas.drawCircle(center, 8, Paint()..color = _rOrange);
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = _rWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPreviewPainter oldDelegate) {
    return oldDelegate.route != route;
  }
}

class _SummaryRouteTransform {
  const _SummaryRouteTransform({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
    required this.size,
  });

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;
  final Size size;

  static _SummaryRouteTransform? fromSegments(
    List<List<RunLocationSample>> segments,
    Size size,
  ) {
    final points = segments.expand((segment) => segment).toList();
    if (points.isEmpty) {
      return null;
    }

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;
    for (final point in points.skip(1)) {
      minLatitude = point.latitude < minLatitude ? point.latitude : minLatitude;
      maxLatitude = point.latitude > maxLatitude ? point.latitude : maxLatitude;
      minLongitude = point.longitude < minLongitude
          ? point.longitude
          : minLongitude;
      maxLongitude = point.longitude > maxLongitude
          ? point.longitude
          : maxLongitude;
    }

    return _SummaryRouteTransform(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
      size: size,
    );
  }

  Offset offsetFor(RunLocationSample sample) {
    final longitudeRange = maxLongitude - minLongitude;
    final latitudeRange = maxLatitude - minLatitude;
    final x = longitudeRange == 0
        ? 0.5
        : ((sample.longitude - minLongitude) / longitudeRange).clamp(0.0, 1.0);
    final y = latitudeRange == 0
        ? 0.5
        : (1 - (sample.latitude - minLatitude) / latitudeRange).clamp(0.0, 1.0);
    final padding = size.shortestSide * 0.18;
    final drawableWidth = (size.width - padding * 2).clamp(1.0, size.width);
    final drawableHeight = (size.height - padding * 2).clamp(1.0, size.height);
    return Offset(padding + drawableWidth * x, padding + drawableHeight * y);
  }
}

class _PaceChartPainter extends CustomPainter {
  const _PaceChartPainter({required this.graph, required this.isLockedPreview});

  final PaceGraphSnapshot graph;
  final bool isLockedPreview;

  @override
  void paint(Canvas canvas, Size size) {
    final horizontalInset = size.width > (_paceChartHorizontalPlotInset * 2)
        ? _paceChartHorizontalPlotInset
        : 0.0;
    final plotLeft = horizontalInset;
    final plotRight = size.width - horizontalInset;
    final plotWidth = (plotRight - plotLeft).clamp(1.0, double.infinity);

    double xForDisplayProgress(double progressFraction) {
      return plotLeft + (progressFraction.clamp(0.0, 1.0) * plotWidth);
    }

    double displayProgressForPoint(int index) {
      return paceChartDisplayProgressForPoint(
        index: index,
        pointCount: graph.points.length,
        rawProgressFraction: graph.points[index].progressFraction,
      );
    }

    final guidePaint = Paint()
      ..color = _rBlue10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final y in [8.0, 36.0, 64.0, 92.0]) {
      _drawDashedLine(
        canvas,
        Offset(plotLeft, y),
        Offset(plotRight, y),
        guidePaint,
      );
    }

    if (!graph.isAvailable || graph.points.length < 3) {
      return;
    }

    final rangeMin = graph.paceRangeMinSecondsPerKm;
    final rangeMax = graph.paceRangeMaxSecondsPerKm;
    if (rangeMin == null || rangeMax == null) {
      return;
    }
    final paceRange = rangeMax - rangeMin;

    double yForSeconds(int paceSecondsPerKm) {
      if (paceRange <= 0) {
        return size.height / 2;
      }
      return ((paceSecondsPerKm - rangeMin) / paceRange) * size.height;
    }

    final offsets = <_PaceChartPointOffset>[];
    for (var i = 0; i < graph.points.length; i += 1) {
      final graphPoint = graph.points[i];
      offsets.add(
        _PaceChartPointOffset(
          point: graphPoint,
          offset: Offset(
            xForDisplayProgress(displayProgressForPoint(i)),
            yForSeconds(graphPoint.paceSecondsPerKm),
          ),
        ),
      );
    }

    final line = Path();
    for (var i = 0; i < offsets.length; i += 1) {
      final point = offsets[i].offset;
      if (i == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
    }
    final firstPoint = offsets.first.offset;
    final lastPoint = offsets.last.offset;
    final area = Path.from(line)
      ..lineTo(lastPoint.dx, size.height)
      ..lineTo(firstPoint.dx, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..color = isLockedPreview
            ? const Color(0x12FB6414)
            : const Color(0x14FB6414),
    );
    final averagePace = graph.averagePaceSecondsPerKm;
    if (!isLockedPreview &&
        averagePace != null &&
        averagePace >= rangeMin &&
        averagePace <= rangeMax) {
      _drawDashedLine(
        canvas,
        Offset(plotLeft, yForSeconds(averagePace)),
        Offset(plotRight, yForSeconds(averagePace)),
        Paint()
          ..color = _rBlue60
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.75,
      );
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = isLockedPreview ? const Color(0x66FB6414) : _rOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = isLockedPreview ? 2 : 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (!isLockedPreview) {
      _drawMarker(
        canvas,
        point: graph.slowestPacePoint,
        offsets: offsets,
        fillColor: _rWhite,
        strokeColor: _rBlue45,
      );
      _drawMarker(
        canvas,
        point: graph.bestPacePoint,
        offsets: offsets,
        fillColor: _rOrange,
        strokeColor: _rWhite,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 2.0;
    const dashSpace = 4.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(x + dashWidth, end.dy),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  void _drawMarker(
    Canvas canvas, {
    required PaceGraphPoint? point,
    required List<_PaceChartPointOffset> offsets,
    required Color fillColor,
    required Color strokeColor,
  }) {
    if (point == null) {
      return;
    }

    final center = _offsetForPoint(offsets, point);
    if (center == null) {
      return;
    }
    canvas.drawCircle(center, 4.5, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      4.5,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Offset? _offsetForPoint(
    List<_PaceChartPointOffset> offsets,
    PaceGraphPoint point,
  ) {
    for (final candidate in offsets) {
      if (identical(candidate.point, point)) {
        return candidate.offset;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant _PaceChartPainter oldDelegate) {
    return oldDelegate.graph != graph ||
        oldDelegate.isLockedPreview != isLockedPreview;
  }
}

class _PaceChartPointOffset {
  const _PaceChartPointOffset({required this.point, required this.offset});

  final PaceGraphPoint point;
  final Offset offset;
}
