part of 'weekly_workout_detail_screen.dart';

class _WorkoutBreakdownCard extends StatelessWidget {
  const _WorkoutBreakdownCard(this.steps);

  final List<WorkoutStepDisplay> steps;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session breakdown', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++) ...[
            _WorkoutStepRow(steps[index]),
            if (index < steps.length - 1)
              const Divider(height: 20, color: RuniacColors.border),
          ],
        ],
      ),
    );
  }
}

class _WorkoutStepRow extends StatelessWidget {
  const _WorkoutStepRow(this.step);

  final WorkoutStepDisplay step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: _softIconDecoration,
          child: Icon(step.icon, color: RuniacColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.title, style: _bodyStrongStyle),
              const SizedBox(height: 3),
              Text(step.copy, style: _bodyStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _EffortGuideCard extends StatelessWidget {
  const _EffortGuideCard(this.copy);

  final String copy;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Effort guide', style: _sectionTitleStyle),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var index = 0; index < 5; index++) ...[
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: index < 2
                          ? RuniacColors.primaryBlue
                          : const Color(0xFFE8EEF8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (index < 4) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(copy, style: _bodyStyle),
        ],
      ),
    );
  }
}

class _CoachNoteCard extends StatelessWidget {
  const _CoachNoteCard(this.notes);

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: RuniacColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Text('R', style: _coachInitialStyle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach note', style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  for (final note in notes) ...[
                    Text(note, style: _bodyStyle),
                    if (note != notes.last) const SizedBox(height: 5),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartRunAction extends StatelessWidget {
  const _StartRunAction(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.accentOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: _startActionStyle),
    );
  }
}

Future<void> _showEditScheduleSheet(
  BuildContext context,
  WeeklyWorkoutDetailSnapshot snapshot,
  ValueChanged<WorkoutScheduleEditSelection>? onScheduleChanged,
) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RuniacColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) => _EditScheduleSheet(
      snapshot: snapshot,
      onScheduleChanged: onScheduleChanged,
    ),
  );
  if (saved != true || !context.mounted) {
    return;
  }
  await showRuniacSuccessCheckOverlay(context, message: 'Schedule updated.');
}
