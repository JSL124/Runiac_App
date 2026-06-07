import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/crossed_placeholder.dart';
import '../../../../core/widgets/dashboard_card.dart';

const _sportOrange = Color(0xFFFF7A1A);
const _placeholderGrayBlue = Color(0xFFE8EEF7);

const _recommendedRoutesDisplaySnapshot = _RecommendedRoutesDisplaySnapshot(
  title: 'Recommended Routes',
  message: 'Community routes will appear here.',
);

class RecommendedRoutesCard extends StatelessWidget {
  const RecommendedRoutesCard({super.key});

  @override
  Widget build(BuildContext context) {
    const snapshot = _recommendedRoutesDisplaySnapshot;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.route_outlined,
            title: snapshot.title,
            accent: true,
          ),
          const SizedBox(height: 12),
          Text(
            snapshot.message,
            style: const TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          const _RouteCarouselPlaceholder(),
        ],
      ),
    );
  }
}

class _RecommendedRoutesDisplaySnapshot {
  const _RecommendedRoutesDisplaySnapshot({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

class _RouteCarouselPlaceholder extends StatelessWidget {
  const _RouteCarouselPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                child: CrossedPlaceholder(width: 94, height: 92),
              ),
              CrossedPlaceholder(width: 110, height: 108),
              Positioned(
                right: 10,
                child: CrossedPlaceholder(width: 94, height: 92),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CarouselDot(active: true),
            SizedBox(width: 6),
            _CarouselDot(),
            SizedBox(width: 6),
            _CarouselDot(),
          ],
        ),
      ],
    );
  }
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 7 : 5,
      height: active ? 7 : 5,
      decoration: BoxDecoration(
        color: active ? _sportOrange : _placeholderGrayBlue,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
