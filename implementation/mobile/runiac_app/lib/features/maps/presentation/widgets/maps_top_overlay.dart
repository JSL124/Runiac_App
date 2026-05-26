import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class MapsTopOverlay extends StatelessWidget {
  const MapsTopOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _MapsSearchField()),
        SizedBox(width: 8),
        _SavedRoutesButton(),
      ],
    );
  }
}

class _MapsSearchField extends StatelessWidget {
  const _MapsSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1E7F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14172033),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: RuniacColors.primaryBlue, size: 22),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search routes or parks',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedRoutesButton extends StatelessWidget {
  const _SavedRoutesButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x332F50C7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14172033),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            color: RuniacColors.primaryBlue,
            size: 19,
          ),
          SizedBox(width: 6),
          Text(
            'Saved',
            style: TextStyle(
              color: RuniacColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
