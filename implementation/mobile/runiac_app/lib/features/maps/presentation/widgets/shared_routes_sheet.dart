import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../shared_route_detail_screen.dart';
import 'shared_route_sheet_card.dart';

const _homeAccentBlue = Color(0xFF2F5BFF);
const _homeAccentOrange = Color(0xFFF97316);
const _sheetAnimationDuration = Duration(milliseconds: 220);
const _expandedSheetHeight = 405.0;
const _allRoutesSheetHeight = 625.0;
const _collapsedSheetHeight = 46.0;

const _sharedRoutesDisplaySnapshot = _SharedRoutesDisplaySnapshot(
  title: 'Shared Routes',
  allRoutesTitle: 'All shared routes',
  seeAllActionLabel: 'See all',
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
  ],
);

class SharedRoutesSheet extends StatefulWidget {
  const SharedRoutesSheet({super.key});

  @override
  State<SharedRoutesSheet> createState() => _SharedRoutesSheetState();
}

class _SharedRoutesSheetState extends State<SharedRoutesSheet> {
  double _sheetProgress = 1;
  bool _isShowingAllRoutes = false;

  double get _currentExpandedSheetHeight =>
      _isShowingAllRoutes ? _allRoutesSheetHeight : _expandedSheetHeight;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy /
                      (_currentExpandedSheetHeight - _collapsedSheetHeight))
              .clamp(0, 1);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
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

  void _showAllRoutes() {
    setState(() {
      _isShowingAllRoutes = true;
      _sheetProgress = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiddenSheetHeight =
        (_currentExpandedSheetHeight - _collapsedSheetHeight) *
        (1 - _sheetProgress);

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
                height: _currentExpandedSheetHeight,
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
                    onSeeAllTap: _showAllRoutes,
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
    required this.onSeeAllTap,
  });

  final bool isCollapsed;
  final bool isShowingAllRoutes;
  final VoidCallback onSeeAllTap;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MapsSheetAccentStrip(),
                  const SizedBox(height: 10),
                  _SharedRoutesHeader(
                    isShowingAllRoutes: isShowingAllRoutes,
                    onSeeAllTap: onSeeAllTap,
                  ),
                  const SizedBox(height: 10),
                  for (final entry
                      in snapshot
                          .visibleRouteCards(
                            isShowingAllRoutes: isShowingAllRoutes,
                          )
                          .indexed) ...[
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
                                    (context, animation, secondaryAnimation) {
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
    return Center(
      child: Container(
        key: const Key('maps_sheet_handle'),
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: RuniacColors.textSecondary.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
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
  });

  final bool isShowingAllRoutes;
  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    const snapshot = _sharedRoutesDisplaySnapshot;

    return Row(
      children: [
        Expanded(
          child: Text(
            isShowingAllRoutes ? snapshot.allRoutesTitle : snapshot.title,
            style: const TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        if (!isShowingAllRoutes)
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('maps_see_all_shared_routes'),
              borderRadius: BorderRadius.circular(999),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: onSeeAllTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  snapshot.seeAllActionLabel,
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
    required this.allRoutesTitle,
    required this.seeAllActionLabel,
    required this.routeCards,
  });

  final String title;
  final String allRoutesTitle;
  final String seeAllActionLabel;
  final List<_RouteCardDisplaySnapshot> routeCards;

  Iterable<_RouteCardDisplaySnapshot> visibleRouteCards({
    required bool isShowingAllRoutes,
  }) {
    return routeCards.take(isShowingAllRoutes ? 5 : 3);
  }
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
