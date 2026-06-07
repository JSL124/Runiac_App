import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import 'route_preview_card.dart';

const _homeAccentBlue = Color(0xFF2F5BFF);
const _homeAccentOrange = Color(0xFFF97316);
const _sheetAnimationDuration = Duration(milliseconds: 220);
const _expandedSheetHeight = 370.0;
const _collapsedSheetHeight = 46.0;
const _sheetBottomPadding = 14.0;

const _sharedRoutesDisplaySnapshot = _SharedRoutesDisplaySnapshot(
  title: 'Shared Routes',
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
  ],
);

class SharedRoutesSheet extends StatefulWidget {
  const SharedRoutesSheet({super.key});

  @override
  State<SharedRoutesSheet> createState() => _SharedRoutesSheetState();
}

class _SharedRoutesSheetState extends State<SharedRoutesSheet> {
  double _sheetProgress = 1;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _sheetProgress =
          (_sheetProgress -
                  details.delta.dy /
                      (_expandedSheetHeight - _collapsedSheetHeight))
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

  @override
  Widget build(BuildContext context) {
    final hiddenSheetHeight =
        (_expandedSheetHeight - _collapsedSheetHeight) * (1 - _sheetProgress);

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
                height: _expandedSheetHeight,
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
  const _SharedRoutesSheetBody({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    const snapshot = _sharedRoutesDisplaySnapshot;

    if (isCollapsed) {
      return const KeyedSubtree(
        key: Key('maps_sheet_body'),
        child: _SheetHandleArea(),
      );
    }

    return KeyedSubtree(
      key: const Key('maps_sheet_body'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, _sheetBottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandleArea(),
            const _MapsSheetAccentStrip(),
            const SizedBox(height: 10),
            const _SharedRoutesHeader(),
            const SizedBox(height: 10),
            _SharedRouteCard(snapshot: snapshot.routeCards[0]),
            const SizedBox(height: 8),
            _SharedRouteCard(snapshot: snapshot.routeCards[1]),
            const SizedBox(height: 8),
            _SharedRouteCard(snapshot: snapshot.routeCards[2]),
          ],
        ),
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
          color: RuniacColors.border,
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
  const _SharedRoutesHeader();

  @override
  Widget build(BuildContext context) {
    const snapshot = _sharedRoutesDisplaySnapshot;

    return Text(
      snapshot.title,
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }
}

class _SharedRouteCard extends StatelessWidget {
  const _SharedRouteCard({required this.snapshot});

  final _RouteCardDisplaySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return RoutePreviewCard(
      key: Key('route_preview_card_${snapshot.keySuffix}'),
      title: snapshot.title,
      message: snapshot.message,
    );
  }
}

class _SharedRoutesDisplaySnapshot {
  const _SharedRoutesDisplaySnapshot({
    required this.title,
    required this.routeCards,
  });

  final String title;
  final List<_RouteCardDisplaySnapshot> routeCards;
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
