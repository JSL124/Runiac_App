import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RouteDetailHeader extends StatelessWidget {
  const RouteDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      child: Row(
        children: [
          Semantics(
            label: 'Back',
            button: true,
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              color: RuniacColors.primaryBlue,
            ),
          ),
          const Expanded(
            child: Text(
              'Route',
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Semantics(
            label: 'Share route',
            button: true,
            child: IconButton(
              tooltip: 'Share route',
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              color: RuniacColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class RouteDetailBottomActionBar extends StatelessWidget {
  const RouteDetailBottomActionBar({
    required this.isBookmarked,
    required this.onBookmark,
    required this.onSelectRoute,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback? onSelectRoute;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RuniacColors.white,
        border: Border(top: BorderSide(color: RuniacColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10172033),
            blurRadius: 16,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 56,
                child: Semantics(
                  label: 'Save route',
                  button: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: RuniacColors.white,
                      border: Border.all(color: RuniacColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      tooltip: 'Save route',
                      onPressed: onBookmark,
                      color: RuniacColors.primaryBlue,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 29,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RuniacColors.primaryBlue,
                    disabledBackgroundColor: const Color(0xFFC9D5FF),
                    foregroundColor: RuniacColors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Select Route',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteDetailSavingOverlay extends StatelessWidget {
  const RouteDetailSavingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x8A0F172A),
        child: Center(
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RuniacColors.white,
              border: Border.all(color: RuniacColors.border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F172033),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: RuniacColors.primaryBlue),
                SizedBox(height: 18),
                Text(
                  'Setting up your next run...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
