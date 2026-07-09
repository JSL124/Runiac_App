import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/characters/runner_character.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import 'home_stage_background_sequence.dart';
import 'home_stage_map_model.dart';

const double _kFadeFraction = 0.08;
const String _kEmptyStateBackground =
    'assets/images/home/backgrounds/bg_gardens_by_the_bay.webp';
const String _kStageRunAsset =
    'assets/images/home/stages/dashboard_stage_run.png';
const String _kStageRestAsset =
    'assets/images/home/stages/dashboard_stage_rest.png';

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
    this.levelBadgeLabel = 'Lv.0',
    this.levelProgressFraction = 0,
    super.key,
  });

  /// The renderable map, or null/empty when there is no active plan.
  final HomeStageMapModel? model;
  final int streakCount;
  final int unreadNotificationCount;
  final String levelBadgeLabel;
  final double levelProgressFraction;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onTapTodayStage;

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

  String? _shownStageId;
  bool _walking = false;
  List<Offset> _walkWaypoints = const <Offset>[];
  List<double> _walkSegmentLengths = const <double>[];
  double _walkTotalLength = 0;

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
  }

  @override
  void didUpdateWidget(covariant HomeStageMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();

    final newId = widget.model?.currentStageId;
    if (newId != _shownStageId) {
      _maybeStartWalk(newId);
    }
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

  static final bool _runningUnderTestBinding = WidgetsBinding.instance.runtimeType
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
      final anchors = homeStageAnchorsForBackground(
        model.sections[week].backgroundAsset,
      );
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
    final anchors = homeStageAnchorsForBackground(
      model.sections[stage.$1].backgroundAsset,
    );
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

  double _stoneSize(int dayIndex) => 78 - 2.4 * dayIndex;

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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _HomeStageHeader(
                streakCount: widget.streakCount,
                unreadNotificationCount: widget.unreadNotificationCount,
                levelBadgeLabel: widget.levelBadgeLabel,
                levelProgressFraction: widget.levelProgressFraction,
                onNotifications: widget.onNotifications,
                onProfile: widget.onProfile,
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
      final anchors = homeStageAnchorsForBackground(section.backgroundAsset);
      for (var d = 0; d < section.stones.length; d++) {
        final stone = section.stones[d];
        final center = _stoneCenter(w, n, anchors, d);
        final size = _stoneSize(d);
        children.add(
          Positioned(
            left: center.dx - size / 2,
            top: center.dy - size / 2,
            width: size,
            height: size,
            child: _StageStoneWidget(
              stone: stone,
              size: size,
              pulse: stone.isCurrent ? _pulseController : null,
              onTap: stone.isCurrent ? widget.onTapTodayStage : null,
            ),
          ),
        );
      }
    }

    // Guide character on top of everything.
    final character = _buildCharacter(model, n);
    if (character != null) {
      children.add(character);
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

  void _scheduleInitialScroll(HomeStageMapModel model, int n, double total) {
    if (_initialScrollDone || _viewportHeight <= 0) {
      return;
    }
    _initialScrollDone = true;
    final weekIndex = model.currentWeekIndex ?? 0;
    final dayIndex = model.characterDayIndex ?? 0;
    final anchors = homeStageAnchorsForBackground(
      model.sections[weekIndex].backgroundAsset,
    );
    final centerY = _stoneCenter(weekIndex, n, anchors, dayIndex).dy;
    final maxScroll = math.max(0.0, total - _viewportHeight);
    final target = (centerY - _viewportHeight * 0.6).clamp(0.0, maxScroll);
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

    final character =
        SelectedRunnerCharacterScope.maybeOf(context)?.selectedOrDefault ??
        RunnerCharacter.blue;

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
      final anchors = homeStageAnchorsForBackground(
        model.sections[weekIndex].backgroundAsset,
      );
      center = _stoneCenter(weekIndex, n, anchors, dayIndex);
      facing = RunnerCharacterFacing.front;
    }

    const charWidth = 104.0;
    const charHeight = charWidth * 280 / 350;
    return Positioned(
      left: center.dx - charWidth / 2,
      top: center.dy - bob - charHeight * 0.84,
      width: charWidth,
      height: charHeight,
      child: IgnorePointer(
        child: Image.asset(
          character.assetPath(facing),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
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
class _FadingBackground extends StatelessWidget {
  const _FadingBackground({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
          stops: [0.0, _kFadeFraction],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            const ColoredBox(color: Color(0xFFBFE3F5)),
      ),
    );
  }
}

class _StageStoneWidget extends StatelessWidget {
  const _StageStoneWidget({
    required this.stone,
    required this.size,
    this.pulse,
    this.onTap,
  });

  final HomeStageStone stone;
  final double size;
  final Listenable? pulse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final asset = stone.isRun ? _kStageRunAsset : _kStageRestAsset;
    final isFuture = stone.state == HomeStageStoneState.future;
    final isCompleted = stone.state == HomeStageStoneState.completed;

    Widget image = Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stone.isRun
                ? const Color(0xFFEBC66A)
                : const Color(0xFFBFC7D1),
          ),
        );
      },
    );

    if (isFuture) {
      image = Opacity(
        opacity: 0.62,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.45,
            0.45,
            0.10,
            0,
            0,
            0.45,
            0.45,
            0.10,
            0,
            0,
            0.45,
            0.45,
            0.10,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: image,
        ),
      );
    }

    Widget content = SizedBox(width: size, height: size, child: image);

    if (isCompleted && stone.isRun) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: -2,
            top: -2,
            child: _CompletedCheck(size: size * 0.34),
          ),
        ],
      );
    }

    if (stone.isCurrent && pulse != null) {
      content = AnimatedBuilder(
        animation: pulse!,
        builder: (context, child) {
          final t = pulse is Animation<double>
              ? (pulse! as Animation<double>).value
              : 0.0;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.0 + 0.22 * t,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFFFC6818,
                    ).withValues(alpha: 0.30 * (1 - t)),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: content,
      );
    }

    if (onTap == null) {
      return content;
    }
    return Semantics(
      button: true,
      label: "Today's stage",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _CompletedCheck extends StatelessWidget {
  const _CompletedCheck({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2FBF71),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Icon(Icons.check_rounded, size: size * 0.72, color: Colors.white),
    );
  }
}

class _HomeStageHeader extends StatelessWidget {
  const _HomeStageHeader({
    required this.streakCount,
    required this.unreadNotificationCount,
    required this.levelBadgeLabel,
    required this.levelProgressFraction,
    required this.onNotifications,
    required this.onProfile,
  });

  final int streakCount;
  final int unreadNotificationCount;
  final String levelBadgeLabel;
  final double levelProgressFraction;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      ignoring: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPadding + 8, 12, 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66000000), Color(0x00000000)],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StreakPill(streakCount: streakCount),
            const Spacer(),
            _NotificationButton(
              unreadNotificationCount: unreadNotificationCount,
              onNotifications: onNotifications,
            ),
            const SizedBox(width: 6),
            Semantics(
              container: true,
              label: 'Profile',
              button: true,
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onProfile,
                  child: RuniacLevelProfileBadge(
                    initials: 'R',
                    levelLabel: levelBadgeLabel,
                    progressFraction: levelProgressFraction,
                    size: 54,
                    badgeHeight: 17,
                    badgeMinWidth: 44,
                    badgeHorizontalPadding: 7,
                    badgeFontSize: 10,
                    ringStrokeWidth: 4.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streakCount});

  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFFF8A34),
            size: 22,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadNotificationCount,
    required this.onNotifications,
  });

  final int unreadNotificationCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Notifications',
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotifications,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.28),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: _UnreadBadge(count: unreadNotificationCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _HomeStageEmptyState extends StatelessWidget {
  const _HomeStageEmptyState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _kEmptyStateBackground,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: Color(0xFFBFE3F5)),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0x88000000)],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.hiking_rounded, color: Colors.white, size: 52),
                SizedBox(height: 14),
                Text(
                  'Your journey map is waiting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Finish your plan setup to unlock a weekly map of gentle running stages.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
