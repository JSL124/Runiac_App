import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../domain/models/run_tracking_snapshot.dart';
import '../../domain/models/run_tracking_state.dart';

const _panelTextBlue = Color(0xFF3151C8);
const _sportOrange = Color(0xFFFF7A1A);
const _mutedBlue = Color(0xFF8296E8);
const _blueBorder = Color(0xFFDCE6FF);

class RunTrackingSheetContent extends StatelessWidget {
  const RunTrackingSheetContent({
    super.key,
    required this.state,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
  });

  final RunTrackingState state;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final snapshot = RunTrackingSnapshot.fromState(state);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProgressSummaryRow(snapshot: snapshot),
            const SizedBox(height: 8),
            _RunProgressBar(progress: snapshot.planProgressValue),
            SizedBox(height: compact ? 16 : 18),
            _DistanceFocus(snapshot: snapshot),
            SizedBox(height: compact ? 14 : 16),
            const Divider(height: 1, color: _blueBorder),
            SizedBox(height: compact ? 12 : 14),
            _SecondaryMetricRow(snapshot: snapshot),
            SizedBox(height: compact ? 14 : 18),
            _RunActiveActions(
              isPaused: state.isPaused,
              onPause: onPause,
              onResume: onResume,
              onFinish: onFinish,
            ),
          ],
        );
      },
    );
  }
}

class _ProgressSummaryRow extends StatelessWidget {
  const _ProgressSummaryRow({required this.snapshot});

  final RunTrackingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            snapshot.planProgressLabel,
            style: const TextStyle(
              color: _mutedBlue,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          snapshot.planProgressPercentLabel,
          style: const TextStyle(
            color: _panelTextBlue,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RunProgressBar extends StatelessWidget {
  const _RunProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        key: const Key('run_plan_progress_bar'),
        value: progress,
        minHeight: 8,
        backgroundColor: const Color(0xFFE5EAFF),
        color: _sportOrange,
      ),
    );
  }
}

class _DistanceFocus extends StatelessWidget {
  const _DistanceFocus({required this.snapshot});

  final RunTrackingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DISTANCE',
            style: TextStyle(
              color: _mutedBlue,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                snapshot.distanceValueLabel,
                style: const TextStyle(
                  color: _panelTextBlue,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 0.92,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  snapshot.distanceUnitLabel,
                  style: const TextStyle(
                    color: _mutedBlue,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecondaryMetricRow extends StatelessWidget {
  const _SecondaryMetricRow({required this.snapshot});

  final RunTrackingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(label: 'TIME', value: snapshot.elapsedTimeLabel),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: _blueBorder),
          Expanded(
            child: _MetricItem(
              label: 'AVG PACE',
              value: snapshot.averagePaceLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _mutedBlue,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: _panelTextBlue,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
        ),
      ],
    );
  }
}

class _RunActiveActions extends StatelessWidget {
  const _RunActiveActions({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
  });

  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: isPaused ? onResume : onPause,
              icon: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              ),
              label: Text(isPaused ? 'Resume' : 'Pause'),
              style: FilledButton.styleFrom(
                backgroundColor: _panelTextBlue,
                foregroundColor: RuniacColors.white,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Finish'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _panelTextBlue,
                side: const BorderSide(color: _blueBorder, width: 1.5),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
