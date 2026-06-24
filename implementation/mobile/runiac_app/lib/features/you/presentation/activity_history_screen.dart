import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../run/domain/models/run_activity_display_model.dart';
import 'data/activity_history_demo_snapshots.dart';
import 'widgets/compact_run_activity_card.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({
    required this.activityHistoryMonths,
    required this.onBack,
    required this.onActivitySelected,
    super.key,
  });

  final List<ActivityHistoryMonth> activityHistoryMonths;
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
                      for (final month in activityHistoryMonths) ...[
                        _MonthHeader(month: month),
                        const SizedBox(height: 10),
                        for (final activity in month.activities) ...[
                          CompactRunActivityCard(
                            key: ValueKey(
                              'activity_history_card_${activity.identityKey}',
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

  final ActivityHistoryMonth month;

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
