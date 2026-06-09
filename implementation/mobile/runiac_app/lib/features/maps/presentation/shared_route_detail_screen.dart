import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/shared_route_detail_actions.dart';
import 'widgets/shared_route_detail_sections.dart';

class SharedRouteDetailScreen extends StatefulWidget {
  const SharedRouteDetailScreen({super.key});

  @override
  State<SharedRouteDetailScreen> createState() =>
      _SharedRouteDetailScreenState();
}

class _SharedRouteDetailScreenState extends State<SharedRouteDetailScreen> {
  bool _isBookmarked = false;
  bool _isSaving = false;
  bool _isSelected = false;

  Future<void> _confirmRouteSelection() async {
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isBookmarked = true;
      _isSelected = true;
    });
    _showSuccessSheet();
  }

  void _showConfirmSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: RuniacColors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select this route?',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This will replace your current selected route.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              const RouteMetricStrip(compact: true),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _confirmRouteSelection,
                style: FilledButton.styleFrom(
                  backgroundColor: RuniacColors.primaryBlue,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirm Route'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: RuniacColors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Route selected',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This route has been saved and set for your next run.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: RuniacColors.primaryBlue,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Start Run'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('View Planned Routes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Stay Here'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const RouteDetailHeader(),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: ListView(
                      key: const Key('shared_route_detail_scroll_view'),
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                      children: const [
                        RouteDetailAccentStrip(),
                        SizedBox(height: 14),
                        RouteDetailHero(),
                        SizedBox(height: 24),
                        RouteDetailElevationSection(),
                        SizedBox(height: 26),
                        RouteDetailRunnerNotes(),
                        SizedBox(height: 12),
                        RouteDetailHiddenFailureCopy(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RouteDetailBottomActionBar(
              isBookmarked: _isBookmarked,
              onBookmark: () => setState(() => _isBookmarked = !_isBookmarked),
              onSelectRoute: _isSelected ? null : _showConfirmSheet,
            ),
          ),
          if (_isSaving) const RouteDetailSavingOverlay(),
        ],
      ),
    );
  }
}
