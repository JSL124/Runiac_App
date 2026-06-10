import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/maps_background.dart';
import 'widgets/maps_top_overlay.dart';
import 'widgets/shared_routes_sheet.dart';

class MapsTab extends StatefulWidget {
  const MapsTab({super.key});

  @override
  State<MapsTab> createState() => _MapsTabState();
}

class _MapsTabState extends State<MapsTab> {
  bool _isSearchActive = false;

  void _activateSearchPreview() {
    setState(() {
      _isSearchActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: MapsBackground()),
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 14),
              child: MapsTopOverlay(
                isSearchActive: _isSearchActive,
                onSearchTap: _activateSearchPreview,
              ),
            ),
          ),
          const SharedRoutesSheet(),
        ],
      ),
    );
  }
}
