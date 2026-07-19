import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/widgets/runiac_level_profile_badge.dart';

void main() {
  const badgeSize = 96.0;
  const strokeWidth = 8.0;
  const startAngle = math.pi * 5 / 6;
  const gaugeSweep = math.pi * 4 / 3;
  const ringRect = Rect.fromLTWH(
    strokeWidth / 2,
    strokeWidth / 2,
    badgeSize - strokeWidth,
    badgeSize - strokeWidth,
  );

  Future<void> pumpBadge(
    WidgetTester tester, {
    required double progressFraction,
    String levelLabel = 'Lv.1',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RuniacLevelProfileBadge(
              initials: 'B',
              levelLabel: levelLabel,
              progressFraction: progressFraction,
              size: badgeSize,
              ringStrokeWidth: strokeWidth,
            ),
          ),
        ),
      ),
    );
  }

  Finder findBadgeRing() {
    return find.descendant(
      of: find.byType(RuniacLevelProfileBadge),
      matching: find.byType(CustomPaint),
    );
  }

  testWidgets('XP ring paints a bottom-open 240 degree gauge track', (
    WidgetTester tester,
  ) async {
    await pumpBadge(tester, progressFraction: 0);

    expect(findBadgeRing(), paintsExactlyCountTimes(#drawArc, 1));
    expect(
      findBadgeRing(),
      paints..arc(
        rect: ringRect,
        startAngle: startAngle,
        sweepAngle: gaugeSweep,
        useCenter: false,
        strokeWidth: strokeWidth,
        style: PaintingStyle.stroke,
        strokeCap: StrokeCap.round,
      ),
    );
  });

  testWidgets('XP ring maps fifty percent to half of the visible gauge', (
    WidgetTester tester,
  ) async {
    await pumpBadge(tester, progressFraction: 0.5);

    expect(findBadgeRing(), paintsExactlyCountTimes(#drawArc, 2));
    expect(
      findBadgeRing(),
      paints
        ..arc(
          rect: ringRect,
          startAngle: startAngle,
          sweepAngle: gaugeSweep,
          useCenter: false,
          strokeWidth: strokeWidth,
          style: PaintingStyle.stroke,
          strokeCap: StrokeCap.round,
        )
        ..arc(
          rect: ringRect,
          startAngle: startAngle,
          sweepAngle: gaugeSweep * 0.5,
          useCenter: false,
          strokeWidth: strokeWidth,
          style: PaintingStyle.stroke,
          strokeCap: StrokeCap.round,
        ),
    );
  });

  testWidgets('XP ring clamps overfilled progress to the visible gauge', (
    WidgetTester tester,
  ) async {
    await pumpBadge(tester, progressFraction: 1.4, levelLabel: 'Lv.100');

    expect(find.text('Lv.100'), findsOneWidget);
    expect(findBadgeRing(), paintsExactlyCountTimes(#drawArc, 2));
    expect(
      findBadgeRing(),
      paints
        ..arc(
          rect: ringRect,
          startAngle: startAngle,
          sweepAngle: gaugeSweep,
          useCenter: false,
          strokeWidth: strokeWidth,
          style: PaintingStyle.stroke,
          strokeCap: StrokeCap.round,
        )
        ..arc(
          rect: ringRect,
          startAngle: startAngle,
          sweepAngle: gaugeSweep,
          useCenter: false,
          strokeWidth: strokeWidth,
          style: PaintingStyle.stroke,
          strokeCap: StrokeCap.round,
        ),
    );
  });

  testWidgets('compact two-letter initials stay centered inside the disc', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RuniacLevelProfileBadge(
              initials: 'AR',
              levelLabel: 'Lv.12',
              progressFraction: 0,
              size: 42,
              badgeHeight: 16,
              badgeMinWidth: 42,
              badgeHorizontalPadding: 6,
              badgeFontSize: 9,
              ringStrokeWidth: 4,
            ),
          ),
        ),
      ),
    );

    final initials = tester.widget<Text>(find.text('AR'));
    expect(initials.textAlign, TextAlign.center);
    expect(
      find.ancestor(of: find.text('AR'), matching: find.byType(FittedBox)),
      findsOneWidget,
    );
  });
}
