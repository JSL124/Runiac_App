import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_background_sequence.dart';

void main() {
  group('stableFnv1aHash', () {
    test('is deterministic for the same input', () {
      expect(stableFnv1aHash('plan-abc'), stableFnv1aHash('plan-abc'));
    });

    test('differs for different inputs and stays within 32 bits', () {
      final a = stableFnv1aHash('plan-abc');
      final b = stableFnv1aHash('plan-abd');
      expect(a, isNot(b));
      expect(a, inInclusiveRange(0, 0xFFFFFFFF));
      expect(b, inInclusiveRange(0, 0xFFFFFFFF));
    });
  });

  group('homeStageBackgroundSequence', () {
    test('returns exactly weekCount backgrounds', () {
      final sequence = homeStageBackgroundSequence(
        planId: 'plan-1',
        weekCount: 8,
      );
      expect(sequence, hasLength(8));
      for (final asset in sequence) {
        expect(kHomeStageBackgroundAssets, contains(asset));
      }
    });

    test('is identical for the same plan id (pure, no storage)', () {
      final first = homeStageBackgroundSequence(planId: 'plan-x', weekCount: 12);
      final second = homeStageBackgroundSequence(
        planId: 'plan-x',
        weekCount: 12,
      );
      expect(first, second);
    });

    test('never repeats within the last two used backgrounds', () {
      for (final id in <String>['a', 'plan-42', 'runiac-999', 'zzz']) {
        final sequence = homeStageBackgroundSequence(
          planId: id,
          weekCount: 16,
        );
        for (var i = 0; i < sequence.length; i++) {
          if (i >= 1) {
            expect(
              sequence[i],
              isNot(sequence[i - 1]),
              reason: 'week $i repeats the previous background for $id',
            );
          }
          if (i >= 2) {
            expect(
              sequence[i],
              isNot(sequence[i - 2]),
              reason: 'week $i repeats the background two before it for $id',
            );
          }
        }
      }
    });

    test('different plan ids generally differ', () {
      final a = homeStageBackgroundSequence(planId: 'plan-a', weekCount: 8);
      final b = homeStageBackgroundSequence(planId: 'plan-b', weekCount: 8);
      expect(a, isNot(b));
    });

    test('handles a single-background palette and zero weeks', () {
      expect(
        homeStageBackgroundSequence(planId: 'p', weekCount: 0),
        isEmpty,
      );
      final single = homeStageBackgroundSequence(
        planId: 'p',
        weekCount: 4,
        palette: const ['only.webp'],
      );
      expect(single, ['only.webp', 'only.webp', 'only.webp', 'only.webp']);
    });
  });

  group('homeStageAnchorsForBackground', () {
    test('every declared background has 7 in-range anchors', () {
      for (final asset in kHomeStageBackgroundAssets) {
        final anchors = homeStageAnchorsForBackground(asset);
        expect(anchors, hasLength(7), reason: asset);
        for (final anchor in anchors) {
          expect(anchor.dx, inInclusiveRange(0.0, 1.0), reason: asset);
          expect(anchor.dy, inInclusiveRange(0.0, 1.0), reason: asset);
        }
        // Day 1 (index 0) sits lower on the image than day 7 (index 6).
        expect(anchors.first.dy, greaterThan(anchors.last.dy), reason: asset);
      }
    });

    test('falls back to a default anchor set for unknown assets', () {
      expect(homeStageAnchorsForBackground('missing.webp'), hasLength(7));
    });
  });
}
