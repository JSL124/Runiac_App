import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../run/data/mock_health_workout_import_repository.dart';
import '../../run/domain/models/imported_workout_candidate.dart';
import '../../run/domain/repositories/health_workout_import_repository.dart';

class WatchHealthAppsScreen extends StatefulWidget {
  const WatchHealthAppsScreen({
    this.repository = const MockHealthWorkoutImportRepository(),
    super.key,
  });

  final HealthWorkoutImportRepository repository;

  @override
  State<WatchHealthAppsScreen> createState() => _WatchHealthAppsScreenState();
}

class _WatchHealthAppsScreenState extends State<WatchHealthAppsScreen> {
  late final Future<List<ImportedWorkoutCandidate>> _candidatesFuture;

  @override
  void initState() {
    super.initState();
    _candidatesFuture = widget.repository.listRecentRunningWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Watch & Health Apps',
              tooltip: 'Back to Account',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _IntroCard(),
                      const SizedBox(height: 18),
                      const _ConnectionSection(),
                      const SizedBox(height: 22),
                      const _SectionLabel('Runs found from your health apps'),
                      const SizedBox(height: 8),
                      _CandidateSection(candidatesFuture: _candidatesFuture),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuniacColors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect your watch runs',
              style: TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bring in completed runs from Apple Health, Garmin, or Health Connect.',
              style: TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionSection extends StatelessWidget {
  const _ConnectionSection();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuniacColors.border),
      ),
      child: const Column(
        children: [
          _ConnectionRow(
            icon: Icons.favorite_border_rounded,
            title: 'Apple Health',
            subtitle: 'Preview ready',
          ),
          Divider(height: 1, thickness: 1, color: RuniacColors.border),
          _ConnectionRow(
            icon: Icons.health_and_safety_outlined,
            title: 'Health Connect',
            subtitle: 'Preview ready',
          ),
          Divider(height: 1, thickness: 1, color: RuniacColors.border),
          _ConnectionRow(
            icon: Icons.watch_outlined,
            title: 'Garmin via Health',
            subtitle: 'Available through health sync',
          ),
        ],
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          _IconTile(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateSection extends StatelessWidget {
  const _CandidateSection({required this.candidatesFuture});

  final Future<List<ImportedWorkoutCandidate>> candidatesFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImportedWorkoutCandidate>>(
      future: candidatesFuture,
      builder: (context, snapshot) {
        final candidates = snapshot.data;
        if (candidates == null) {
          return const _LoadingCard();
        }

        return Column(
          children: [
            for (var index = 0; index < candidates.length; index++) ...[
              _CandidateCard(candidate: candidates[index]),
              if (index != candidates.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.innerTileSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'Finding recent watch runs...',
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate});

  final ImportedWorkoutCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final helperText = candidate.heartRateHelperText == null
        ? null
        : 'Heart rate was not shared';

    return RuniacTappableSurface(
      semanticLabel: '${candidate.sourceLabel} watch run preview',
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Adding watch runs comes next.')),
          );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconTile(icon: _sourceIcon(candidate)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.sourceLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _friendlyStartedAt(candidate.startedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: RuniacColors.textSecondary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricPill(label: 'Distance', value: _distance(candidate)),
              _MetricPill(label: 'Duration', value: _duration(candidate)),
              _MetricPill(label: 'Avg pace', value: _pace(candidate)),
              _MetricPill(
                label: 'Avg HR',
                value: candidate.avgHeartRateDisplay,
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 10),
            Text(
              helperText,
              style: const TextStyle(
                color: RuniacColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayText = '$label $value';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.innerTileSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RuniacColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          displayText,
          style: const TextStyle(
            color: RuniacColors.textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.sectionSurfaceStrong,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: RuniacColors.primaryBlue, size: 18),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: RuniacColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

IconData _sourceIcon(ImportedWorkoutCandidate candidate) {
  return switch (candidate.sourceLabel) {
    'Apple Health' => Icons.favorite_border_rounded,
    'Health Connect' => Icons.health_and_safety_outlined,
    _ => Icons.watch_outlined,
  };
}

String _distance(ImportedWorkoutCandidate candidate) {
  return '${(candidate.distanceMeters / 1000).toStringAsFixed(2)} km';
}

String _duration(ImportedWorkoutCandidate candidate) {
  final minutes = (candidate.durationSeconds / 60).round();
  return '$minutes min';
}

String _pace(ImportedWorkoutCandidate candidate) {
  final minutes = candidate.avgPaceSecondsPerKm ~/ 60;
  final seconds = candidate.avgPaceSecondsPerKm % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
}

String _friendlyStartedAt(DateTime startedAt) {
  const monthLabels = <int, String>{
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
  final hour = startedAt.hour % 12 == 0 ? 12 : startedAt.hour % 12;
  final minute = startedAt.minute.toString().padLeft(2, '0');
  final suffix = startedAt.hour >= 12 ? 'PM' : 'AM';
  return '${startedAt.day} ${monthLabels[startedAt.month]} · $hour:$minute $suffix';
}
