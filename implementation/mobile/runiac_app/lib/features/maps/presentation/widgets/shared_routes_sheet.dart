import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_bottom_sheet_handle.dart';
import '../shared_route_detail_screen.dart';
import 'shared_route_sheet_card.dart';

const _homeAccentBlue = Color(0xFF2F5BFF);
const _homeAccentOrange = Color(0xFFF97316);
const _sheetAnimationDuration = Duration(milliseconds: 220);
const _previewSheetHeight = 405.0;
const _expandedSheetScreenFraction = 0.7;
const _collapsedSheetHeight = 46.0;

const _sharedRoutesDisplaySnapshot = _SharedRoutesDisplaySnapshot(
  title: 'Shared Routes',
  seeAllActionLabel: 'See all',
  showLessActionLabel: 'Show less',
  routeCards: [
    _RouteCardDisplaySnapshot(
      keySuffix: 'route_preview',
      title: 'Route preview',
      message: 'A calm route card can guide the next step later.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'shared_routes',
      title: 'Shared routes',
      message: 'Community route ideas remain review-only for now.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'saved_routes',
      title: 'Saved routes',
      message: 'Saved route slots stay visible without saving data.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'park_connector',
      title: 'Park connector loop',
      message: 'Flat route inspiration stays static and review-only.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'morning_waterfront',
      title: 'Morning waterfront',
      message: 'Gentle community ideas appear without loading data.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'marina_bay_easy',
      title: 'Marina Bay easy route',
      message: 'A simple waterfront idea for relaxed route browsing.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'garden_evening',
      title: 'Garden evening loop',
      message: 'A calm garden loop stays static until routes are real.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'beginner_riverside',
      title: 'Beginner riverside route',
      message: 'Short riverside inspiration keeps the preview friendly.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'coffee_recovery',
      title: 'Coffee stop recovery route',
      message: 'Recovery route ideas remain display-only and gentle.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'quiet_neighbourhood',
      title: 'Quiet neighbourhood loop',
      message: 'Low-pressure neighbourhood browsing for future routes.',
    ),
    _RouteCardDisplaySnapshot(
      keySuffix: 'sunset_recovery',
      title: 'Sunset recovery route',
      message: 'An easy sunset route card for the static list preview.',
    ),
  ],
);

class SharedRoutesSheet extends StatefulWidget {
  const SharedRoutesSheet({super.key});

  @override
  State<SharedRoutesSheet> createState() => _SharedRoutesSheetState();
}

class _SharedRoutesSheetState extends State<SharedRoutesSheet> {
  final _expandedRoutesScrollController = ScrollController();

  double _sheetProgress = 1;
  bool _isShowingAllRoutes = false;

  double _currentSheetHeight(double screenHeight) {
    if (_isShowingAllRoutes) {
      return screenHeight * _expandedSheetScreenFraction;
    }

    return _previewSheetHeight;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_isShowingAllRoutes && details.delta.dy > 0) {
        _isShowingAllRoutes = false;
      }

      final sheetHeight = _currentSheetHeight(
        MediaQuery.sizeOf(context).height,
      );
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy / (sheetHeight - _collapsedSheetHeight))
              .clamp(0, 1);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    setState(() {
      final nextProgress = _sheetProgress >= 0.5 ? 1.0 : 0.0;

      if (velocity > 260) {
        _sheetProgress = 0;
      } else if (velocity < -260) {
        _sheetProgress = 1;
      } else {
        _sheetProgress = nextProgress;
      }

      if (_sheetProgress == 0) {
        _isShowingAllRoutes = false;
      }
    });
  }

  void _showAllRoutes() {
    if (_expandedRoutesScrollController.hasClients) {
      _expandedRoutesScrollController.jumpTo(0);
    }

    setState(() {
      _isShowingAllRoutes = true;
      _sheetProgress = 1;
    });
  }

  void _showLess() {
    if (_expandedRoutesScrollController.hasClients) {
      _expandedRoutesScrollController.jumpTo(0);
    }

    setState(() {
      _isShowingAllRoutes = false;
      _sheetProgress = 1;
    });
  }

  @override
  void dispose() {
    _expandedRoutesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = _currentSheetHeight(MediaQuery.sizeOf(context).height);
    final hiddenSheetHeight =
        (sheetHeight - _collapsedSheetHeight) * (1 - _sheetProgress);

    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: _sheetAnimationDuration,
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: -hiddenSheetHeight,
            child: GestureDetector(
              key: const Key('maps_sheet_surface'),
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: SizedBox(
                height: sheetHeight,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: RuniacColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A172033),
                        blurRadius: 18,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: _SharedRoutesSheetBody(
                    isCollapsed: _sheetProgress <= 0.01,
                    isShowingAllRoutes: _isShowingAllRoutes,
                    expandedRoutesScrollController:
                        _expandedRoutesScrollController,
                    onSeeAllTap: _showAllRoutes,
                    onShowLessTap: _showLess,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedRoutesSheetBody extends StatelessWidget {
  const _SharedRoutesSheetBody({
    required this.isCollapsed,
    required this.isShowingAllRoutes,
    required this.expandedRoutesScrollController,
    required this.onSeeAllTap,
    required this.onShowLessTap,
  });

  final bool isCollapsed;
  final bool isShowingAllRoutes;
  final ScrollController expandedRoutesScrollController;
  final VoidCallback onSeeAllTap;
  final VoidCallback onShowLessTap;

  @override
  Widget build(BuildContext context) {
    const snapshot = _sharedRoutesDisplaySnapshot;

    return KeyedSubtree(
      key: const Key('maps_sheet_body'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandleArea(),
          if (!isCollapsed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MapsSheetAccentStrip(),
                    const SizedBox(height: 10),
                    _SharedRoutesHeader(
                      isShowingAllRoutes: isShowingAllRoutes,
                      onSeeAllTap: onSeeAllTap,
                      onShowLessTap: onShowLessTap,
                    ),
                    const SizedBox(height: 10),
                    if (isShowingAllRoutes)
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(overscroll: false),
                          child: ListView.separated(
                            key: const Key('maps_expanded_shared_routes_list'),
                            controller: expandedRoutesScrollController,
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            itemCount: snapshot.expandedRouteCards.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final route = snapshot.expandedRouteCards[index];
                              return SharedRouteSheetCard(
                                keySuffix: route.keySuffix,
                                title: route.title,
                                message: route.message,
                                onTap: index == 0
                                    ? () => Navigator.of(context).push(
                                        PageRouteBuilder<void>(
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return const SharedRouteDetailScreen();
                                              },
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      )
                    else
                      for (final entry
                          in snapshot.previewRouteCards.indexed) ...[
                        if (entry.$1 > 0) const SizedBox(height: 8),
                        SharedRouteSheetCard(
                          keySuffix: entry.$2.keySuffix,
                          title: entry.$2.title,
                          message: entry.$2.message,
                          onTap: entry.$1 == 0
                              ? () => Navigator.of(context).push(
                                  PageRouteBuilder<void>(
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return const SharedRouteDetailScreen();
                                        },
                                  ),
                                )
                              : null,
                        ),
                      ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SheetHandleArea extends StatelessWidget {
  const _SheetHandleArea();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 46, child: Center(child: _SheetDragHandle()));
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return const RuniacBottomSheetHandle(
      key: Key('maps_sheet_handle'),
      width: 44,
      height: 5,
    );
  }
}

class _MapsSheetAccentStrip extends StatelessWidget {
  const _MapsSheetAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('maps_sheet_accent_strip'),
      children: [
        Expanded(
          child: Container(
            key: const Key('maps_sheet_accent_blue'),
            height: 4,
            decoration: BoxDecoration(
              color: _homeAccentBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(key: Key('maps_sheet_accent_gap'), width: 8),
        Container(
          key: const Key('maps_sheet_accent_orange'),
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: _homeAccentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _SharedRoutesHeader extends StatelessWidget {
  const _SharedRoutesHeader({
    required this.isShowingAllRoutes,
    required this.onSeeAllTap,
    required this.onShowLessTap,
  });

  final bool isShowingAllRoutes;
  final VoidCallback onSeeAllTap;
  final VoidCallback onShowLessTap;

  @override
  Widget build(BuildContext context) {
    const snapshot = _sharedRoutesDisplaySnapshot;

    return Row(
      children: [
        Expanded(
          child: Text(
            snapshot.title,
            style: const TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key(
              isShowingAllRoutes
                  ? 'maps_show_less_shared_routes'
                  : 'maps_see_all_shared_routes',
            ),
            borderRadius: BorderRadius.circular(999),
            onTap: isShowingAllRoutes ? onShowLessTap : onSeeAllTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                isShowingAllRoutes
                    ? snapshot.showLessActionLabel
                    : snapshot.seeAllActionLabel,
                style: const TextStyle(
                  color: RuniacColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SharedRoutesDisplaySnapshot {
  const _SharedRoutesDisplaySnapshot({
    required this.title,
    required this.seeAllActionLabel,
    required this.showLessActionLabel,
    required this.routeCards,
  });

  final String title;
  final String seeAllActionLabel;
  final String showLessActionLabel;
  final List<_RouteCardDisplaySnapshot> routeCards;

  Iterable<_RouteCardDisplaySnapshot> get previewRouteCards =>
      routeCards.take(3);

  List<_RouteCardDisplaySnapshot> get expandedRouteCards => routeCards;
}

class _RouteCardDisplaySnapshot {
  const _RouteCardDisplaySnapshot({
    required this.keySuffix,
    required this.title,
    required this.message,
  });

  final String keySuffix;
  final String title;
  final String message;
}
