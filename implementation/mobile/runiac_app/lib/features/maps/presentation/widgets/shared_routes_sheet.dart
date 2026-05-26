import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import 'route_preview_card.dart';

class SharedRoutesSheet extends StatelessWidget {
  const SharedRoutesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.055,
      initialChildSize: 0.38,
      maxChildSize: 0.5,
      snap: true,
      snapSizes: const [0.055, 0.38, 0.5],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A172033),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            physics: const ClampingScrollPhysics(),
            children: const [
              _SheetHandleArea(),
              _SharedRoutesHeader(),
              SizedBox(height: 14),
              RoutePreviewCard(
                title: 'Route preview',
                message: 'A calm route card can guide the next step later.',
              ),
              SizedBox(height: 10),
              RoutePreviewCard(
                title: 'Shared routes',
                message: 'Community route ideas remain review-only for now.',
              ),
              SizedBox(height: 10),
              RoutePreviewCard(
                title: 'Saved routes',
                message: 'Saved route slots stay visible without saving data.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandleArea extends StatelessWidget {
  const _SheetHandleArea();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 60, child: Center(child: _SheetDragHandle()));
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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

class _SharedRoutesHeader extends StatelessWidget {
  const _SharedRoutesHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Shared Routes',
      style: TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }
}
