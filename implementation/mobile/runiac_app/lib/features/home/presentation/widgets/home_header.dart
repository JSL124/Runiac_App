import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';

const _brandBlue = RuniacColors.primaryBlue;
const _sportOrange = RuniacColors.accentOrange;

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAccentBar(),
              SizedBox(height: 12),
              Text(
                'Good to see you',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your Home dashboard is ready for a calm start.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        _HomeProfilePlaceholder(),
      ],
    );
  }
}

class _HomeProfilePlaceholder extends StatelessWidget {
  const _HomeProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      height: 58,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 7,
            child: RuniacIconTileButton(
              icon: Icons.notifications_none,
              onPressed: () {},
              semanticLabel: 'Notifications',
              size: 44,
              iconColor: RuniacColors.textPrimary,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: RuniacIconTileButton(
              icon: Icons.person_outline,
              onPressed: () {},
              semanticLabel: 'Profile',
              size: 54,
              iconSize: 30,
              iconColor: RuniacColors.textSecondary,
              borderColor: RuniacColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAccentBar extends StatelessWidget {
  const _HomeAccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: _brandBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: _sportOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
