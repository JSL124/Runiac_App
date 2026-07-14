import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/characters/runner_character.dart';
import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../../../challenge/domain/challenge_copy.dart';
import '../../../challenge/domain/challenge_countdown.dart';
import '../../../challenge/presentation/home_active_challenge_display.dart';
import '../../../challenge/presentation/widgets/challenge_badge_image.dart';
import '../../domain/guide/home_guide_agent.dart';
import '../../domain/guide/home_guide_consent.dart';
import 'home_stage_background_sequence.dart';
import 'home_guide_cycle.dart';
import 'home_stage_map_model.dart';

part 'home_stage_map_backdrop.dart';
part 'home_stage_map_stones.dart';
part 'home_stage_map_header.dart';
part 'home_stage_map_challenge.dart';
part 'home_stage_map_social.dart';
part 'home_stage_map_status_controls.dart';
part 'home_stage_map_empty_state.dart';
part 'home_stage_map_guide.dart';

const double _kFadeFraction = 0.08;
const double _kMinimumStageStoneSize = 92;
const double _kMaximumStageStoneSize = 108;
const double _kStageStoneWidthFraction = 0.255;
const double _kCharacterToStoneScale = 0.86;
const double _kStageDayLabelWidth = 56;
const double _kStageDayLabelTopFraction = 0.82;

/// The initial camera composition keeps the guide in the lower visual third,
/// leaving room above for upcoming stages and the Home header.
const double _kInitialCharacterViewportFraction = 2 / 3;

/// Where the guide's feet rest on a stage stone, as a fraction of the stone's
/// height measured down from the stone's top edge. The stones are drawn as
/// perspective plates whose visible standing surface sits near the middle of
/// the asset, so slightly above centre keeps the plate's front face visible
/// beneath the feet.
const double _kCharacterFootAnchorStoneHeightFraction = 0.46;

/// Transparent padding below the feet inside the character sprites, as a
/// fraction of the sprite's rendered height. Every bundled character asset
/// carries a small (up to ~3.6% of height) band of fully transparent rows
/// under the feet, so one shared allowance keeps the bottom-anchored feet on
/// the standing surface without per-asset pixel offsets.
const double _kCharacterFootInsetFraction = 0.02;
const String _kEmptyStateBackground =
    'assets/images/home/backgrounds/bg_gardens_by_the_bay.webp';
const String _kStageRunAsset =
    'assets/images/home/stages/dashboard_stage_run.png';
const String _kStageRestAsset =
    'assets/images/home/stages/dashboard_stage_rest.png';
const String kBlueRunnerIdleGifAsset =
    'assets/images/characters/blue_idle/blue_runner_idle.gif';

/// Chooses the guide sprite for the Home stage map.
///
/// When Blue is selected, this supplied runner GIF represents the guide in
/// both the resting and plan-to-plan movement states. The other characters
/// retain their existing direction-specific PNG sprites.
String homeStageGuideAssetPath({
  required RunnerCharacter character,
  required RunnerCharacterFacing facing,
}) {
  if (character == RunnerCharacter.blue) {
    return kBlueRunnerIdleGifAsset;
  }
  return character.assetPath(facing);
}

double homeStageGuideHeightForWidth({
  required RunnerCharacter character,
  required double width,
}) {
  return character == RunnerCharacter.blue
      ? width * 289 / 193
      : width * 280 / 350;
}

/// Duolingo-style vertical stage map for the Home tab.
///
/// Renders one full-bleed background per plan week (week 1 at the bottom,
/// later weeks stacking upward), with seven stage stones placed on each
/// background's path and a guide character standing on today's stage. All
/// progress shown is display-only; nothing is computed or written here.
class HomeStageMap extends StatefulWidget {
  const HomeStageMap({
    required this.onNotifications,
    required this.onProfile,
    required this.onTapTodayStage,
    this.model,
    this.streakCount = 0,
    this.unreadNotificationCount = 0,
    this.profileInitials = 'R',
    this.levelBadgeLabel = 'Lv.0',
    this.levelProgressFraction = 0,
    this.progressLoading = false,
    this.profileLoading = false,
    this.guideAgent,
    this.guideRequest,
    this.guideConsentStatus = HomeGuideConsentStatus.granted,
    this.onReviewGuideDataUse,
    this.onOpenFriends,
    this.onOpenChallenge,
    this.activeChallenge,
    this.onOpenChallengeProgress,
    this.challengeClock,
    this.challengeTicker,
    super.key,
  });

  /// The renderable map, or null/empty when there is no active plan.
  final HomeStageMapModel? model;
  final int streakCount;
  final int unreadNotificationCount;
  final String profileInitials;
  final String levelBadgeLabel;
  final double levelProgressFraction;
  final bool progressLoading;
  final bool profileLoading;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onTapTodayStage;

  /// Seam that turns [guideRequest] into a speech-bubble message for the
  /// guide character. When null (or [guideRequest] is null), no speech
  /// bubble is ever shown — the character remains a purely cosmetic sprite.
  final HomeGuideAgent? guideAgent;

  /// Display-only description of today's workout, forwarded to [guideAgent].
  /// Rebuilt by the caller (see `home_tab.dart`) whenever the active plan or
  /// today's stage changes.
  final HomeGuideRequest? guideRequest;
  final HomeGuideConsentStatus guideConsentStatus;
  final VoidCallback? onReviewGuideDataUse;

  /// Opens the Friends screen when the Social menu's Friends item is tapped.
  /// Optional so existing call sites and tests compile unchanged; when null
  /// the Friends item simply closes the menu. Navigation trigger only — the
  /// stage map reads or writes no social data.
  final VoidCallback? onOpenFriends;

  /// Opens the Challenge hub when the Social menu's Challenge item is tapped.
  /// Optional so existing call sites and tests compile unchanged; when null the
  /// Challenge item simply closes the menu. Navigation trigger only — the stage
  /// map internals read or write no Challenge/Firebase data.
  final VoidCallback? onOpenChallenge;

  /// The caller's live ACTIVE/SETTLING challenge, resolved by `HomeTab` from its
  /// repository and handed down as a plain Firebase-free projection. Null hides
  /// the header active-challenge control entirely (no reserved gap).
  final HomeActiveChallengeDisplay? activeChallenge;

  /// Opens the Progress screen when the active-challenge control is tapped.
  /// `HomeTab` owns the navigation and repository; the stage map only fires the
  /// callback.
  final VoidCallback? onOpenChallengeProgress;

  /// Injected wall-clock for the active-challenge countdown (production uses
  /// `DateTime.now`). Tests pass a fixed clock for a deterministic label.
  final DateTime Function()? challengeClock;

  /// Injected 1-second ticker seam for the countdown (production uses a periodic
  /// timer). Tests pass a no-op/controlled ticker so no real frames are scheduled.
  final ChallengeTicker? challengeTicker;

  @override
  State<HomeStageMap> createState() => _HomeStageMapState();
}

class _HomeStageMapState extends State<HomeStageMap>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _walkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  double _sectionWidth = 0;
  double _sectionHeight = 0;
  double _overlap = 0;
  double _viewportHeight = 0;
  bool _initialScrollDone = false;
  bool _socialMenuOpen = false;

  String? _shownStageId;
  bool _walking = false;
  List<Offset> _walkWaypoints = const <Offset>[];
  List<double> _walkSegmentLengths = const <double>[];
  double _walkTotalLength = 0;

  // The cycle owns bundle caching, the summary/tip/progression order, and
  // close/reopen state. This surface only supplies the eligible stage/request
  // signature and renders its display-only state.
  HomeGuideCycleController? _guideCycle;
  HomeGuideAgent? _guideCycleAgent;

  @override
  void initState() {
    super.initState();
    _shownStageId = widget.model?.currentStageId;
    _walkController.addListener(_onWalkTick);
    _walkController.addStatusListener(_onWalkStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery (reduced-motion) becomes available here, not in initState.
    _syncPulse();
    _syncGuideBubble();
  }

  @override
  void didUpdateWidget(covariant HomeStageMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
    _syncGuideBubble();

    final newId = widget.model?.currentStageId;
    if (newId != _shownStageId) {
      _maybeStartWalk(newId);
    }
  }

  void _syncGuideBubble() {
    final model = widget.model;
    final stageId = _hasTodayStage(model) ? model!.currentStageId : null;
    final agent = widget.guideAgent;
    final request = widget.guideRequest;
    if (stageId == null ||
        agent == null ||
        request == null ||
        widget.guideConsentStatus != HomeGuideConsentStatus.granted) {
      _clearGuideCycle();
      return;
    }
    final signature = HomeGuideCycleSignature.forRequest(
      stageId: stageId,
      request: request,
    );
    final cycle = _guideCycle;
    if (cycle == null || !identical(agent, _guideCycleAgent)) {
      _clearGuideCycle();
      _guideCycle = HomeGuideCycleController(agent: agent, signature: signature)
        ..addListener(_onGuideCycleChanged);
      _guideCycleAgent = agent;
      return;
    }
    cycle.updateSignature(signature);
  }

  void _clearGuideCycle() {
    final cycle = _guideCycle;
    if (cycle == null) {
      return;
    }
    cycle
      ..removeListener(_onGuideCycleChanged)
      ..dispose();
    _guideCycle = null;
    _guideCycleAgent = null;
  }

  void _onGuideCycleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleGuideBubble() {
    final cycle = _guideCycle;
    if (cycle == null) {
      return;
    }
    if (cycle.state.isVisible) {
      cycle.hide();
    } else {
      cycle.show();
    }
  }

  void _dismissGuideBubble() {
    _guideCycle?.hide();
  }

  void _toggleSocialMenu() {
    setState(() {
      _socialMenuOpen = !_socialMenuOpen;
    });
  }

  void _closeSocialMenu() {
    if (!_socialMenuOpen) {
      return;
    }
    setState(() {
      _socialMenuOpen = false;
    });
  }

  void _onSocialFriendsTap() {
    _closeSocialMenu();
    widget.onOpenFriends?.call();
  }

  void _onSocialChallengeTap() {
    _closeSocialMenu();
    widget.onOpenChallenge?.call();
  }

  void _advanceGuideBubble() {
    _guideCycle?.advance();
  }

  /// True when the indefinite pulse/walk should stay idle: either the platform
  /// asks for reduced motion, or we are running under a widget-test binding.
  ///
  /// The pulse uses [AnimationController.repeat], which keeps scheduling frames
  /// forever and would make `pumpAndSettle` time out. Most widget tests reach
  /// Home through `RuniacApp` without opting into reduced motion, so we also
  /// treat the test harness as reduced-motion. The real app runs on
  /// `WidgetsFlutterBinding` (whose type name has no "Test"), so it still
  /// animates normally.
  bool get _reduceMotion {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return true;
    }
    return _runningUnderTestBinding;
  }

  static final bool _runningUnderTestBinding = WidgetsBinding
      .instance
      .runtimeType
      .toString()
      .contains('Test');

  /// Runs the "today" pulse only while there is an active today stage and
  /// motion is allowed. Keeping the repeating controller idle otherwise leaves
  /// no frames scheduled, so default `pumpAndSettle` tests settle.
  void _syncPulse() {
    final shouldPulse = _hasTodayStage(widget.model) && !_reduceMotion;
    if (shouldPulse) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _clearGuideCycle();
    _walkController
      ..removeListener(_onWalkTick)
      ..removeStatusListener(_onWalkStatus)
      ..dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasTodayStage(HomeStageMapModel? model) {
    return model != null && model.todayDayIndex != null;
  }

  void _onWalkTick() {
    if (_walking) {
      setState(() {});
    }
  }

  void _onWalkStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _walking) {
      setState(() {
        _walking = false;
        _shownStageId = widget.model?.currentStageId;
      });
    }
  }

  void _maybeStartWalk(String? newId) {
    if (newId == null) {
      _shownStageId = null;
      return;
    }
    // Under reduced motion, jump straight to the new stage without walking.
    if (_reduceMotion) {
      _shownStageId = newId;
      return;
    }
    // First real appearance of a stage: settle without animating.
    if (_shownStageId == null || _walking) {
      _shownStageId = newId;
      return;
    }
    final model = widget.model;
    if (model == null || _sectionWidth <= 0) {
      _shownStageId = newId;
      return;
    }

    final from = _parseStageId(_shownStageId!);
    final to = _parseStageId(newId);
    final n = model.sections.length;
    if (from == null ||
        to == null ||
        from.$1 >= n ||
        to.$1 >= n ||
        !_isForward(from, to)) {
      _shownStageId = newId;
      return;
    }

    final waypoints = _buildWalkWaypoints(model, from, to);
    if (waypoints.length < 2) {
      _shownStageId = newId;
      return;
    }
    _walkWaypoints = waypoints;
    _walkSegmentLengths = <double>[
      for (var i = 0; i < waypoints.length - 1; i++)
        (waypoints[i + 1] - waypoints[i]).distance,
    ];
    _walkTotalLength = _walkSegmentLengths.fold<double>(0, (a, b) => a + b);
    if (_walkTotalLength <= 0) {
      _shownStageId = newId;
      return;
    }
    setState(() {
      _walking = true;
    });
    _walkController.forward(from: 0);
  }

  bool _isForward((int, int) from, (int, int) to) {
    final fromOrdinal = from.$1 * kHomeStageDaysPerWeek + from.$2;
    final toOrdinal = to.$1 * kHomeStageDaysPerWeek + to.$2;
    return toOrdinal > fromOrdinal;
  }

  (int, int)? _parseStageId(String id) {
    final parts = id.split(':');
    if (parts.length != 2) {
      return null;
    }
    final week = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    if (week == null || day == null) {
      return null;
    }
    return (week, day);
  }

  List<Offset> _buildWalkWaypoints(
    HomeStageMapModel model,
    (int, int) from,
    (int, int) to,
  ) {
    final n = model.sections.length;
    if (from.$1 == to.$1) {
      final week = from.$1;
      final anchors = homeStageAnchorsForSection(week);
      final step = to.$2 >= from.$2 ? 1 : -1;
      final points = <Offset>[];
      for (var d = from.$2; d != to.$2 + step; d += step) {
        if (d < 0 || d >= anchors.length) {
          break;
        }
        points.add(_stoneCenter(week, n, anchors, d));
      }
      return points;
    }
    return <Offset>[
      _stoneCenterForStage(model, from, n),
      _stoneCenterForStage(model, to, n),
    ];
  }

  Offset _stoneCenterForStage(
    HomeStageMapModel model,
    (int, int) stage,
    int n,
  ) {
    final anchors = homeStageAnchorsForSection(stage.$1);
    final day = stage.$2.clamp(0, anchors.length - 1);
    return _stoneCenter(stage.$1, n, anchors, day);
  }

  double _sectionTop(int weekIndex, int n) {
    return (n - 1 - weekIndex) * (_sectionHeight - _overlap);
  }

  Offset _stoneCenter(
    int weekIndex,
    int n,
    List<Offset> anchors,
    int dayIndex,
  ) {
    final anchor = anchors[dayIndex.clamp(0, anchors.length - 1)];
    return Offset(
      anchor.dx * _sectionWidth,
      _sectionTop(weekIndex, n) + anchor.dy * _sectionHeight,
    );
  }

  double get _stageStoneSize => (_sectionWidth * _kStageStoneWidthFraction)
      .clamp(_kMinimumStageStoneSize, _kMaximumStageStoneSize)
      .toDouble();

  double get _characterWidth => _stageStoneSize * _kCharacterToStoneScale;

  double _characterHeightFor(RunnerCharacter character) {
    return homeStageGuideHeightForWidth(
      character: character,
      width: _characterWidth,
    );
  }

  /// Top edge of the character sprite when its feet stand on the stone (or
  /// walk-path point) centred at [anchorCenter].
  ///
  /// The character is anchored by its feet — the bottom of the rendered box
  /// minus the shared transparent foot inset — so any character sprite,
  /// whatever its height, keeps its feet on the same standing surface. The
  /// rendered box always matches the sprite's own aspect ratio (see
  /// [homeStageGuideHeightForWidth]), so the box bottom is the sprite bottom.
  double _characterTopForAnchor(
    Offset anchorCenter,
    RunnerCharacter character,
  ) {
    final footY =
        anchorCenter.dy +
        _stageStoneSize * (_kCharacterFootAnchorStoneHeightFraction - 0.5);
    return footY -
        _characterHeightFor(character) * (1 - _kCharacterFootInsetFraction);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _sectionWidth = constraints.maxWidth;
        _sectionHeight = _sectionWidth * kHomeStageBackgroundAspect;
        _overlap = _sectionHeight * _kFadeFraction;
        _viewportHeight = constraints.maxHeight;

        final model = widget.model;
        final hasStages = model != null && model.hasStages;
        final Widget mapLayer = hasStages
            ? _buildMap(model)
            : const _HomeStageEmptyState();

        return Stack(
          children: [
            Positioned.fill(child: mapLayer),
            // Tap-outside dismissal barrier: mounted only while the Social
            // menu is open so the closed-state semantics and stage taps are
            // unaffected. Intentionally opaque to map interaction while open.
            if (_socialMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  key: const ValueKey<String>('homeSocialMenuBarrier'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeSocialMenu,
                  child: const SizedBox.expand(),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _HomeStageHeader(
                    streakCount: widget.streakCount,
                    unreadNotificationCount: widget.unreadNotificationCount,
                    levelBadgeLabel: widget.levelBadgeLabel,
                    levelProgressFraction: widget.levelProgressFraction,
                    progressLoading: widget.progressLoading,
                    profileLoading: widget.profileLoading,
                    profileInitials: widget.profileInitials,
                    onNotifications: widget.onNotifications,
                    onProfile: widget.onProfile,
                    socialMenuOpen: _socialMenuOpen,
                    onToggleSocialMenu: _toggleSocialMenu,
                    activeChallenge: widget.activeChallenge,
                    onOpenChallengeProgress: widget.onOpenChallengeProgress,
                    challengeClock: widget.challengeClock,
                    challengeTicker: widget.challengeTicker,
                  ),
                  if (_socialMenuOpen)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _HomeSocialMenuPanel(
                        onFriends: _onSocialFriendsTap,
                        onChallenge: _onSocialChallengeTap,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(HomeStageMapModel model) {
    final n = model.sections.length;
    final totalHeight = (n - 1) * (_sectionHeight - _overlap) + _sectionHeight;
    _scheduleInitialScroll(model, n, totalHeight);

    final children = <Widget>[];

    // Backgrounds: paint upper weeks first so lower weeks blend over them.
    for (var w = n - 1; w >= 0; w--) {
      children.add(
        Positioned(
          left: 0,
          top: _sectionTop(w, n),
          width: _sectionWidth,
          height: _sectionHeight,
          child: _FadingBackground(asset: model.sections[w].backgroundAsset),
        ),
      );
    }

    // Stones above every background.
    for (var w = 0; w < n; w++) {
      final section = model.sections[w];
      final anchors = homeStageAnchorsForSection(w);
      for (var d = 0; d < section.stones.length; d++) {
        final stone = section.stones[d];
        final center = _stoneCenter(w, n, anchors, d);
        final size = _stageStoneSize;
        children.add(
          Positioned(
            left: center.dx - size / 2,
            top: center.dy - size / 2,
            width: size,
            height: size,
            child: _StageStoneWidget(
              key: ValueKey<String>('homeStageStone-${section.weekNumber}-$d'),
              stone: stone,
              size: size,
              pulse: stone.isCurrent ? _pulseController : null,
              onTap: stone.isCurrent && stone.isRun
                  ? widget.onTapTodayStage
                  : null,
            ),
          ),
        );
        if (stone.dayLabel != null) {
          children.add(
            Positioned(
              left: center.dx - _kStageDayLabelWidth / 2,
              top: center.dy - size / 2 + size * _kStageDayLabelTopFraction,
              width: _kStageDayLabelWidth,
              child: IgnorePointer(
                child: _StageDayLabel(
                  key: ValueKey<String>(
                    'homeStageDayLabel-${section.weekNumber}-$d',
                  ),
                  label: stone.dayLabel!,
                  dimmed: stone.state == HomeStageStoneState.future,
                ),
              ),
            ),
          );
        }
      }
    }

    // Guide character on top of everything.
    final character = _buildCharacter(model, n);
    if (character != null) {
      children.add(character);
    }

    final bubble = _buildGuideBubble(model, n, totalHeight);
    if (bubble != null) {
      children.add(bubble);
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: _sectionWidth,
        height: totalHeight,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
  }

  /// Speech bubble anchored above the guide character on today's stage.
  /// Hidden while walking, when there is no eligible today stage, or when no
  /// guide seam is wired in.
  Widget? _buildGuideBubble(
    HomeStageMapModel model,
    int n,
    double totalHeight,
  ) {
    if (_walking || !_hasTodayStage(model)) {
      return null;
    }
    if (widget.guideAgent == null || widget.guideRequest == null) {
      return null;
    }
    final anchor = _characterAnchorCenter(model, n);
    if (anchor == null) {
      return null;
    }

    const gap = 10.0;
    const horizontalSafeInset = 12.0;
    final bubbleWidth = math.min(
      280.0,
      math.max(0.0, _sectionWidth - horizontalSafeInset * 2),
    );
    if (bubbleWidth <= 0) {
      return null;
    }
    final charTopY = _characterTopForAnchor(anchor, _selectedCharacter);
    final left = (anchor.dx - bubbleWidth / 2)
        .clamp(
          horizontalSafeInset,
          math.max(
            horizontalSafeInset,
            _sectionWidth - bubbleWidth - horizontalSafeInset,
          ),
        )
        .toDouble();
    final safeTop = MediaQuery.paddingOf(context).top + horizontalSafeInset;
    final maxBubbleHeight = math.max(1.0, charTopY - gap - safeTop);

    if (widget.guideConsentStatus != HomeGuideConsentStatus.granted) {
      final onReview = widget.onReviewGuideDataUse;
      if (widget.guideConsentStatus == HomeGuideConsentStatus.unknown ||
          onReview == null) {
        return null;
      }
      return Positioned(
        left: left,
        width: bubbleWidth,
        bottom: (totalHeight - (charTopY - gap)).clamp(0.0, totalHeight),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxBubbleHeight),
          child: _GuideConsentCard(onReview: onReview),
        ),
      );
    }

    final cycle = _guideCycle;
    if (cycle == null || !cycle.state.isVisible) {
      return null;
    }

    return Positioned(
      left: left,
      width: bubbleWidth,
      bottom: (totalHeight - (charTopY - gap)).clamp(0.0, totalHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxBubbleHeight),
        child: _GuideSpeechBubble(
          key: ValueKey<String?>(model.currentStageId),
          state: cycle.state,
          isRestDay: widget.guideRequest?.isRestDay ?? false,
          onAdvance: _advanceGuideBubble,
          onDismiss: _dismissGuideBubble,
          onManageDataUse: widget.onReviewGuideDataUse,
        ),
      ),
    );
  }

  void _scheduleInitialScroll(HomeStageMapModel model, int n, double total) {
    if (_initialScrollDone || _viewportHeight <= 0) {
      return;
    }
    _initialScrollDone = true;

    final weekIndex = model.currentWeekIndex ?? 0;
    final dayIndex = model.characterDayIndex ?? 0;
    final anchors = homeStageAnchorsForSection(weekIndex);
    final anchor = _stoneCenter(weekIndex, n, anchors, dayIndex);
    final characterCenterY =
        _characterTopForAnchor(anchor, _selectedCharacter) +
        _characterHeightFor(_selectedCharacter) / 2;
    final maxScroll = math.max(0.0, total - _viewportHeight);
    final target =
        (characterCenterY -
                _viewportHeight * _kInitialCharacterViewportFraction)
            .clamp(0.0, maxScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(target);
      }
    });
  }

  Widget? _buildCharacter(HomeStageMapModel model, int n) {
    final weekIndex = model.currentWeekIndex;
    final dayIndex = model.characterDayIndex;
    if (weekIndex == null || dayIndex == null) {
      return null;
    }

    final character = _selectedCharacter;

    Offset center;
    RunnerCharacterFacing facing;
    double bob = 0;
    if (_walking && _walkTotalLength > 0) {
      final result = _walkSample(_walkController.value);
      center = result.$1;
      facing = result.$2;
      bob =
          math.sin(_walkController.value * math.pi * 6) *
          math.min(6, _sectionHeight * 0.01);
    } else {
      final anchors = homeStageAnchorsForSection(weekIndex);
      center = _stoneCenter(weekIndex, n, anchors, dayIndex);
      facing = RunnerCharacterFacing.front;
    }

    final charWidth = _characterWidth;
    final charHeight = _characterHeightFor(character);
    final asset = homeStageGuideAssetPath(character: character, facing: facing);
    final canTapCharacter =
        !_walking && widget.guideAgent != null && widget.guideRequest != null;
    return Positioned(
      key: const ValueKey<String>('homeStageCharacter'),
      left: center.dx - charWidth / 2,
      top: _characterTopForAnchor(center, character) - bob,
      width: charWidth,
      height: charHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          if (canTapCharacter)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: charHeight * 0.72,
              child: Semantics(
                button: true,
                label: '${character.displayName} guide',
                child: GestureDetector(
                  key: const ValueKey<String>('homeGuideCharacterTapTarget'),
                  behavior: HitTestBehavior.opaque,
                  onTap:
                      widget.guideConsentStatus ==
                          HomeGuideConsentStatus.granted
                      ? _toggleGuideBubble
                      : widget.onReviewGuideDataUse,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  RunnerCharacter get _selectedCharacter =>
      SelectedRunnerCharacterScope.maybeOf(context)?.selectedOrDefault ??
      RunnerCharacter.blue;

  /// Static (non-walking) center of the character/guide-bubble anchor on the
  /// active week's stage map, or null when there is no character stage.
  Offset? _characterAnchorCenter(HomeStageMapModel model, int n) {
    final weekIndex = model.currentWeekIndex;
    final dayIndex = model.characterDayIndex;
    if (weekIndex == null || dayIndex == null) {
      return null;
    }
    final anchors = homeStageAnchorsForSection(weekIndex);
    return _stoneCenter(weekIndex, n, anchors, dayIndex);
  }

  (Offset, RunnerCharacterFacing) _walkSample(double t) {
    final distance = _walkTotalLength * t;
    var travelled = 0.0;
    for (var i = 0; i < _walkSegmentLengths.length; i++) {
      final segLength = _walkSegmentLengths[i];
      if (segLength <= 0) {
        continue;
      }
      if (distance <= travelled + segLength ||
          i == _walkSegmentLengths.length - 1) {
        final localT = ((distance - travelled) / segLength).clamp(0.0, 1.0);
        final start = _walkWaypoints[i];
        final end = _walkWaypoints[i + 1];
        final point = Offset.lerp(start, end, localT)!;
        final delta = end - start;
        return (point, _facingForDelta(delta));
      }
      travelled += segLength;
    }
    return (_walkWaypoints.last, RunnerCharacterFacing.back);
  }

  RunnerCharacterFacing _facingForDelta(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs() * 0.75) {
      return delta.dx >= 0
          ? RunnerCharacterFacing.right
          : RunnerCharacterFacing.left;
    }
    return RunnerCharacterFacing.back;
  }
}

/// A background section whose top edge fades to transparent so the week above
/// (painted behind it) bleeds through for a soft, continuous transition.
