import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'shared_route_detail_screen.dart';

const _selectedRouteSnapshot = SharedRouteDetailSnapshot(
  title: 'Marina Bay easy loop',
  distance: '3.2 km',
  duration: '25 min',
  difficulty: 'Easy',
);

const _favouriteRoutes = <SharedRouteDetailSnapshot>[
  SharedRouteDetailSnapshot(
    title: 'Bishan Park starter route',
    distance: '2.4 km',
    duration: '18 min',
    difficulty: 'Easy',
  ),
  SharedRouteDetailSnapshot(
    title: 'East Coast flat run',
    distance: '4.0 km',
    duration: '32 min',
    difficulty: 'Easy',
  ),
  SharedRouteDetailSnapshot(
    title: 'Punggol waterway loop',
    distance: '3.6 km',
    duration: '28 min',
    difficulty: 'Easy',
  ),
  SharedRouteDetailSnapshot(
    title: 'Kallang riverside run',
    distance: '3.0 km',
    duration: '23 min',
    difficulty: 'Easy',
  ),
];

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  SharedRouteDetailSnapshot? _selectedRoute = _selectedRouteSnapshot;

  @override
  Widget build(BuildContext context) {
    final selectedRoute = _selectedRoute;

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
                    if (selectedRoute == null)
                      const _SelectedRouteEmptyState()
                    else
                      _selectedRouteCard(selectedRoute),
                    const SizedBox(height: 12),
                    _selectedRouteActions(
                      hasSelectedRoute: selectedRoute != null,
                    ),
                    const SizedBox(height: 26),
                    _sectionTitle('Favourite routes'),
                    const SizedBox(height: 12),
                    for (final route in _favouriteRoutes) ...[
                      _favouriteRouteRow(route),
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

  void _openRouteDetail(SharedRouteDetailSnapshot route) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SharedRouteDetailScreen(route: route);
        },
      ),
    );
  }

  Future<void> _showRemoveSelectedRouteDialog() async {
    final selectedRoute = _selectedRoute;
    if (selectedRoute == null) return;

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove selected route?'),
          content: Text(
            'This will remove ${selectedRoute.title} from today’s selected route.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: RuniacColors.accentOrange,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true || !mounted) return;

    setState(() => _selectedRoute = null);
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

  Widget _selectedRouteCard(SharedRouteDetailSnapshot route) {
    return _SavedRouteCard(
      key: const Key('selected_route_card'),
      route: route,
      onTap: () => _openRouteDetail(route),
    );
  }

  Widget _selectedRouteActions({required bool hasSelectedRoute}) {
    return Row(
      children: [
        const Expanded(
          child: _SelectedRouteActionButton(
            key: Key('selected_route_change_action'),
            label: 'Change route',
            primary: true,
          ),
        ),
        if (hasSelectedRoute) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _SelectedRouteActionButton(
              key: const Key('selected_route_remove_action'),
              label: 'Remove',
              onPressed: _showRemoveSelectedRouteDialog,
            ),
          ),
        ],
      ],
    );
  }

  Widget _favouriteRouteRow(SharedRouteDetailSnapshot route) {
    return _SavedRouteCard(route: route, onTap: () => _openRouteDetail(route));
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
}

class _SavedRouteCard extends StatelessWidget {
  const _SavedRouteCard({required this.route, required this.onTap, super.key});

  final SharedRouteDetailSnapshot route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open route details for ${route.title}',
      button: true,
      child: Material(
        color: RuniacColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE1E7F5)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const _RouteThumbnail(size: 62),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: RuniacColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        route.meta,
                        style: const TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _SelectedRouteEmptyState extends StatelessWidget {
  const _SelectedRouteEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('selected_route_empty_state'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE1E7F5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No route selected for today',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Choose a route when you are ready to plan your next run.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteThumbnail extends StatelessWidget {
  const _RouteThumbnail({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FF),
          border: Border.all(color: const Color(0xFFDDE6FF)),
          borderRadius: BorderRadius.circular(16),
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
              child: _ThumbnailDot(RuniacColors.accentOrange, size),
            ),
            Positioned(
              right: size * .2,
              top: size * .2,
              child: _ThumbnailDot(RuniacColors.primaryBlue, size),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailDot extends StatelessWidget {
  const _ThumbnailDot(this.color, this.size);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * .13,
      height: size * .13,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SelectedRouteActionButton extends StatelessWidget {
  const _SelectedRouteActionButton({
    required this.label,
    this.onPressed,
    this.primary = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary
        ? RuniacColors.primaryBlue
        : RuniacColors.textSecondary;
    final background = primary ? const Color(0xFFEFF3FF) : RuniacColors.white;
    final borderColor = primary ? const Color(0xFFDDE6FF) : RuniacColors.border;

    return TextButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: borderColor),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
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
