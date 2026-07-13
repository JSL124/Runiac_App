import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/account/presentation/widgets/account_challenge_badge_case.dart';
import 'package:runiac_app/features/challenge/domain/models/challenge_enums.dart';
import 'package:runiac_app/features/challenge/presentation/widgets/challenge_badge_image.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 300, child: child)),
    ),
  );
}

Map<ChallengeTierId, bool> _dimmedByTier(WidgetTester tester) {
  final badges = tester.widgetList<ChallengeBadgeImage>(
    find.byType(ChallengeBadgeImage),
  );
  return <ChallengeTierId, bool>{
    for (final badge in badges) badge.tierId: badge.dimmed,
  };
}

Map<ChallengeTierId, Rect> _rectByTier(WidgetTester tester) {
  final result = <ChallengeTierId, Rect>{};
  for (final element in find.byType(ChallengeBadgeImage).evaluate()) {
    final badge = element.widget as ChallengeBadgeImage;
    result[badge.tierId] = tester.getRect(find.byWidget(badge));
  }
  return result;
}

void main() {
  testWidgets('default (no data) keeps the static preview: nine full-colour '
      'badges and the preview semantics label', (tester) async {
    await tester.pumpWidget(_harness(const AccountChallengeBadgeCase()));
    await tester.pumpAndSettle();

    final dimmed = _dimmedByTier(tester);
    expect(dimmed.length, 9);
    expect(dimmed.values.every((value) => value == false), isTrue);
    expect(
      find.bySemanticsLabel(
        'Challenge badge case preview with nine collection badges',
      ),
      findsOneWidget,
    );
  });

  testWidgets('earned tiers render full-colour, unearned render desaturated',
      (tester) async {
    await tester.pumpWidget(
      _harness(
        const AccountChallengeBadgeCase(
          ownedTierIds: <ChallengeTierId>{
            ChallengeTierId.k10,
            ChallengeTierId.k42,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dimmed = _dimmedByTier(tester);
    expect(dimmed[ChallengeTierId.k10], isFalse);
    expect(dimmed[ChallengeTierId.k42], isFalse);
    expect(dimmed[ChallengeTierId.k20], isTrue);
    expect(dimmed[ChallengeTierId.k1000], isTrue);
  });

  testWidgets('semantics summary reports the earned count', (tester) async {
    await tester.pumpWidget(
      _harness(
        const AccountChallengeBadgeCase(
          ownedTierIds: <ChallengeTierId>{
            ChallengeTierId.k10,
            ChallengeTierId.k20,
            ChallengeTierId.k42,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Challenge badge case, 3 of 9 badges earned'),
      findsOneWidget,
    );
  });

  testWidgets('geometry and aspect ratio are preserved regardless of earned '
      'state', (tester) async {
    await tester.pumpWidget(
      _harness(const AccountChallengeBadgeCase()),
    );
    await tester.pumpAndSettle();
    final previewAspect = tester
        .widget<AspectRatio>(find.byType(AspectRatio))
        .aspectRatio;
    final previewRects = _rectByTier(tester);

    await tester.pumpWidget(
      _harness(
        const AccountChallengeBadgeCase(
          ownedTierIds: <ChallengeTierId>{ChallengeTierId.k10},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final ownedAspect = tester
        .widget<AspectRatio>(find.byType(AspectRatio))
        .aspectRatio;
    final ownedRects = _rectByTier(tester);

    expect(ownedAspect, previewAspect);
    expect(previewAspect, closeTo(1448 / 1086, 1e-9));
    expect(ownedRects.length, 9);
    for (final tier in previewRects.keys) {
      expect(ownedRects[tier], previewRects[tier], reason: '$tier moved');
    }
  });
}
