import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../run/presentation/models/run_activity_display_model.dart';
import '../../run/presentation/models/run_summary_snapshot.dart';
import 'widgets/compact_run_activity_card.dart';

const activityHistoryDisplayData = [
  _ActivityHistoryMonth(
    label: 'June 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'Saturday Night Run',
        timeAgoLabel: '6 Jun 2026',
        distanceLabel: '5.12 km',
        paceLabel: '6\'45"',
        durationLabel: '34:32',
        summary: RunSummarySnapshot(
          title: 'Saturday Night Run',
          dateLabel: '6 Jun 2026',
          timeLabel: '9:18 PM',
          distanceKm: '5.12',
          avgPace: '6\'45"',
          duration: '34:32',
          avgHeartRate: '145',
          calories: '312',
          routeName: 'East Coast Park Night Loop',
        ),
      ),
      RunActivityDisplayModel(
        title: 'Easy Morning Jog',
        timeAgoLabel: '4 Jun 2026',
        distanceLabel: '4.03 km',
        paceLabel: '6\'30"',
        durationLabel: '30:15',
        summary: RunSummarySnapshot(
          title: 'Easy Morning Jog',
          dateLabel: '4 Jun 2026',
          timeLabel: '6:45 AM',
          distanceKm: '4.03',
          avgPace: '6\'30"',
          duration: '30:15',
          avgHeartRate: '138',
          calories: '242',
          routeName: 'Neighbourhood Easy Loop',
        ),
      ),
      RunActivityDisplayModel(
        title: 'Riverside Recovery',
        timeAgoLabel: '1 Jun 2026',
        distanceLabel: '3.20 km',
        paceLabel: '7\'05"',
        durationLabel: '22:40',
        summary: RunSummarySnapshot(
          title: 'Riverside Recovery',
          dateLabel: '1 Jun 2026',
          timeLabel: '7:05 PM',
          distanceKm: '3.20',
          avgPace: '7\'05"',
          duration: '22:40',
          avgHeartRate: '132',
          calories: '190',
          routeName: 'Riverside Recovery Loop',
        ),
      ),
    ],
  ),
  _ActivityHistoryMonth(
    label: 'May 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'Sunset Loop',
        timeAgoLabel: '28 May 2026',
        distanceLabel: '4.50 km',
        paceLabel: '6\'52"',
        durationLabel: '30:54',
        summary: RunSummarySnapshot(
          title: 'Sunset Loop',
          dateLabel: '28 May 2026',
          timeLabel: '6:12 PM',
          distanceKm: '4.50',
          avgPace: '6\'52"',
          duration: '30:54',
          avgHeartRate: '140',
          calories: '270',
          routeName: 'Sunset Park Loop',
        ),
      ),
      RunActivityDisplayModel(
        title: 'Tuesday Tempo',
        timeAgoLabel: '20 May 2026',
        distanceLabel: '5.00 km',
        paceLabel: '6\'20"',
        durationLabel: '31:40',
        summary: RunSummarySnapshot(
          title: 'Tuesday Tempo',
          dateLabel: '20 May 2026',
          timeLabel: '7:10 PM',
          distanceKm: '5.00',
          avgPace: '6\'20"',
          duration: '31:40',
          avgHeartRate: '148',
          calories: '310',
          routeName: 'Tempo Training Loop',
        ),
      ),
      RunActivityDisplayModel(
        title: 'Park Walk + Run',
        timeAgoLabel: '12 May 2026',
        distanceLabel: '3.80 km',
        paceLabel: '7\'10"',
        durationLabel: '27:14',
        summary: RunSummarySnapshot(
          title: 'Park Walk + Run',
          dateLabel: '12 May 2026',
          timeLabel: '6:40 PM',
          distanceKm: '3.80',
          avgPace: '7\'10"',
          duration: '27:14',
          avgHeartRate: '134',
          calories: '220',
          routeName: 'Neighbourhood Park Loop',
        ),
      ),
    ],
  ),
  _ActivityHistoryMonth(
    label: 'April 2026',
    activities: [
      RunActivityDisplayModel(
        title: 'First 5K Attempt',
        timeAgoLabel: '25 Apr 2026',
        distanceLabel: '5.00 km',
        paceLabel: '7\'25"',
        durationLabel: '37:05',
        summary: RunSummarySnapshot(
          title: 'First 5K Attempt',
          dateLabel: '25 Apr 2026',
          timeLabel: '8:02 AM',
          distanceKm: '5.00',
          avgPace: '7\'25"',
          duration: '37:05',
          avgHeartRate: '142',
          calories: '298',
          routeName: 'First 5K Practice Loop',
        ),
      ),
      RunActivityDisplayModel(
        title: 'Gentle Start',
        timeAgoLabel: '14 Apr 2026',
        distanceLabel: '2.50 km',
        paceLabel: '7\'40"',
        durationLabel: '19:10',
        summary: RunSummarySnapshot(
          title: 'Gentle Start',
          dateLabel: '14 Apr 2026',
          timeLabel: '7:20 AM',
          distanceKm: '2.50',
          avgPace: '7\'40"',
          duration: '19:10',
          avgHeartRate: '128',
          calories: '150',
          routeName: 'Gentle Starter Loop',
        ),
      ),
    ],
  ),
];

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({
    required this.onBack,
    required this.onActivitySelected,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<RunActivityDisplayModel> onActivitySelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RuniacColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Activity History',
              tooltip: 'Back to You',
              onBack: onBack,
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
                      const _FilterRow(),
                      const SizedBox(height: 10),
                      const Text(
                        'Showing your recent activities',
                        style: _helperTextStyle,
                      ),
                      const SizedBox(height: 16),
                      for (final month in activityHistoryDisplayData) ...[
                        _MonthHeader(month: month),
                        const SizedBox(height: 10),
                        for (final activity in month.activities) ...[
                          CompactRunActivityCard(
                            key: ValueKey(
                              'activity_history_card_${activity.title}',
                            ),
                            activity: activity,
                            onTap: () => onActivitySelected(activity),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 8),
                      ],
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

class _ActivityHistoryMonth {
  const _ActivityHistoryMonth({required this.label, required this.activities});

  final String label;
  final List<RunActivityDisplayModel> activities;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _FilterPill(label: 'All years')),
        SizedBox(width: 10),
        Expanded(child: _FilterPill(label: 'All months')),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _pillDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(label, style: _filterTextStyle)),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: RuniacColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month});

  final _ActivityHistoryMonth month;

  @override
  Widget build(BuildContext context) {
    final runLabel = month.activities.length == 1 ? 'run' : 'runs';

    return Row(
      children: [
        Expanded(child: Text(month.label, style: _monthTitleStyle)),
        Text('${month.activities.length} $runLabel', style: _helperTextStyle),
      ],
    );
  }
}

final _pillDecoration = BoxDecoration(
  color: RuniacColors.white,
  borderRadius: BorderRadius.circular(999),
  border: Border.all(color: RuniacColors.border),
);

const _filterTextStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 13,
  fontWeight: FontWeight.w800,
);
const _helperTextStyle = TextStyle(
  color: RuniacColors.textSecondary,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);
const _monthTitleStyle = TextStyle(
  color: RuniacColors.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w900,
);
