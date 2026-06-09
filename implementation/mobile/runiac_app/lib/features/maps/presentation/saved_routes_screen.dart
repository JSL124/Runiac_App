import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';

const _favouriteRoutes = <(String, String)>[
  ('Bishan Park starter route', '2.4 km · 18 min · Easy'),
  ('East Coast flat run', '4.0 km · 32 min · Easy'),
  ('Punggol waterway loop', '3.6 km · 28 min · Easy'),
  ('Kallang riverside run', '3.0 km · 23 min · Easy'),
];

class SavedRoutesScreen extends StatelessWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: ListView(
                  key: const Key('saved_routes_scroll_view'),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _sectionLabel('SELECTED FOR TODAY'),
                    const SizedBox(height: 10),
                    _selectedRouteCard(),
                    const SizedBox(height: 26),
                    _sectionTitle('Favourite routes'),
                    const SizedBox(height: 12),
                    for (final route in _favouriteRoutes) ...[
                      _favouriteRouteRow(route.$1, route.$2),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 8),
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
              'My routes',
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(
        borderColor: const Color(0xFFDDE6FF),
        shadowColor: const Color(0x0F172033),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routeThumbnail(82),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleText('Marina Bay easy loop', fontSize: 18),
                    const SizedBox(height: 6),
                    _metaText('3.2 km · 25 min · Easy'),
                    const SizedBox(height: 10),
                    _readyStatusPill(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Change route'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _favouriteRouteRow(String title, String meta) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(borderColor: const Color(0xFFE1E7F5)),
      child: Row(
        children: [
          _routeThumbnail(62),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleText(title),
                const SizedBox(height: 5),
                _metaText(meta),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _radioCircle(),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({
    required Color borderColor,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      color: RuniacColors.white,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        if (shadowColor != null)
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 7),
            color: shadowColor,
          ),
      ],
    );
  }

  Widget _routeThumbnail(double size) {
    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FF),
          border: Border.all(color: const Color(0xFFDDE6FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned(
              left: size * .14,
              right: size * .14,
              top: size * .46,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: RuniacColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.route_outlined,
                color: RuniacColors.primaryBlue,
                size: size * .42,
              ),
            ),
            Positioned(
              left: size * .22,
              bottom: size * .22,
              child: _thumbnailDot(RuniacColors.accentOrange, size),
            ),
            Positioned(
              right: size * .2,
              top: size * .2,
              child: _thumbnailDot(RuniacColors.primaryBlue, size),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailDot(Color color, double size) {
    return Container(
      width: size * .13,
      height: size * .13,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _readyStatusPill() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        border: Border.all(color: const Color(0xFFFFE2D4)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Ready for today',
          style: TextStyle(
            color: RuniacColors.accentOrange,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _radioCircle() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9AAEEE), width: 2),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: RuniacColors.accentOrange,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _titleText(String title, {double fontSize = 15}) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.18,
      ),
    );
  }

  Widget _metaText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: RuniacColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
