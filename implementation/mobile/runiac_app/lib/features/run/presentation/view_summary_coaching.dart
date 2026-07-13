part of 'view_summary_screen.dart';

class _CoachingSection extends StatelessWidget {
  const _CoachingSection({required this.coachingSummary});

  final CoachingSummarySnapshot coachingSummary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(title: coachingSummary.sectionTitle),
          _CardSurface(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coachingSummary.headline,
                  style: const TextStyle(
                    color: _rBlue,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  coachingSummary.message,
                  style: const TextStyle(
                    color: _rBlue90,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    letterSpacing: -0.1,
                  ),
                ),
                if (coachingSummary.bullets.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final bullet in coachingSummary.bullets)
                    _CoachingBullet(text: bullet),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: _rBlue10),
                const SizedBox(height: 14),
                _NextActionBlock(text: coachingSummary.nextAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachingBullet extends StatelessWidget {
  const _CoachingBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _rOrange,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const SizedBox(width: 5, height: 5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _rBlue75,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionBlock extends StatelessWidget {
  const _NextActionBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Focus',
          style: TextStyle(
            color: _rBlue,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(
            color: _rBlue75,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
