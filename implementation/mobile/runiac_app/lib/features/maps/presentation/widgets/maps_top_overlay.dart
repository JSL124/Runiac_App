import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../saved_routes_screen.dart';

const _mapsTopOverlayDisplaySnapshot = _MapsTopOverlayDisplaySnapshot(
  searchPlaceholder: 'Search routes or parks',
  searchPreviewQuery: 'Marina Bay',
  savedActionLabel: 'Saved',
);

class MapsTopOverlay extends StatelessWidget {
  const MapsTopOverlay({
    required this.isSearchActive,
    required this.onSearchTap,
    super.key,
  });

  final bool isSearchActive;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MapsSearchField(
            isSearchActive: isSearchActive,
            onTap: onSearchTap,
          ),
        ),
        const SizedBox(width: 8),
        const _SavedRoutesButton(),
      ],
    );
  }
}

class _MapsSearchField extends StatelessWidget {
  const _MapsSearchField({required this.isSearchActive, required this.onTap});

  final bool isSearchActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const snapshot = _mapsTopOverlayDisplaySnapshot;

    return Semantics(
      label: 'Maps search preview',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('maps_search_field'),
          borderRadius: BorderRadius.circular(999),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: RuniacColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSearchActive
                    ? RuniacColors.primaryBlue
                    : const Color(0xFFE1E7F5),
                width: isSearchActive ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSearchActive
                      ? const Color(0x242F50C7)
                      : const Color(0x14172033),
                  blurRadius: isSearchActive ? 16 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: RuniacColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isSearchActive
                        ? snapshot.searchPreviewQuery
                        : snapshot.searchPlaceholder,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSearchActive
                          ? RuniacColors.textPrimary
                          : RuniacColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isSearchActive) const _SearchPreviewCursor(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchPreviewCursor extends StatelessWidget {
  const _SearchPreviewCursor();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('maps_search_preview_cursor'),
      width: 2,
      height: 20,
      decoration: BoxDecoration(
        color: RuniacColors.accentOrange,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SavedRoutesButton extends StatelessWidget {
  const _SavedRoutesButton();

  @override
  Widget build(BuildContext context) {
    const snapshot = _mapsTopOverlayDisplaySnapshot;

    return Semantics(
      label: snapshot.savedActionLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () => Navigator.of(context).push(_buildSavedRoutesRoute()),
          child: Container(
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bookmark_border,
                  color: RuniacColors.primaryBlue,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  snapshot.savedActionLabel,
                  style: const TextStyle(
                    color: RuniacColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

PageRouteBuilder<void> _buildSavedRoutesRoute() {
  return PageRouteBuilder<void>(
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SavedRoutesScreen();
    },
  );
}

class _MapsTopOverlayDisplaySnapshot {
  const _MapsTopOverlayDisplaySnapshot({
    required this.searchPlaceholder,
    required this.searchPreviewQuery,
    required this.savedActionLabel,
  });

  final String searchPlaceholder;
  final String searchPreviewQuery;
  final String savedActionLabel;
}
