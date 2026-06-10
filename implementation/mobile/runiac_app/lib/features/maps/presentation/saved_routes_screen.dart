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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _MyRoutesHeaderAccentStrip(),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: ListView(
                  key: const Key('saved_routes_scroll_view'),
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  children: [
                    _sectionLabel('SELECTED FOR TODAY'),
                    const SizedBox(height: 10),
                    _selectedRouteCard(),
                    const SizedBox(height: 12),
                    _selectedRouteActions(),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Semantics(
            label: 'Back',
            button: true,
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: RuniacColors.textPrimary,
            ),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'My routes',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedRouteCard() {
    return Container(
      key: const Key('selected_route_card'),
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
                _titleText('Marina Bay easy loop'),
                const SizedBox(height: 5),
                _metaText('3.2 km · 25 min · Easy'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedRouteActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('Change route'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton(onPressed: () {}, child: const Text('Remove')),
        ),
      ],
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
          _favouriteRouteArrowAffordance(),
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

  Widget _favouriteRouteArrowAffordance() {
    return Container(
      key: const Key('favourite_route_arrow_affordance'),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Icon(
        Icons.arrow_forward,
        color: RuniacColors.primaryBlue,
        size: 17,
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

class _MyRoutesHeaderAccentStrip extends StatelessWidget {
  const _MyRoutesHeaderAccentStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('my_routes_header_accent_strip'),
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: RuniacColors.primaryBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
