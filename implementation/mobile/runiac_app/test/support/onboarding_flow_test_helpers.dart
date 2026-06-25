import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> completeOnboardingToPreview(WidgetTester tester) async {
  await tapText(tester, 'Start setup');
  await answerSingle(tester, 'Build a running habit');
  await answerSingle(tester, 'Completely new to running');
  await answerSingle(tester, '3 days per week');
  for (final day in ['Mon', 'Wed', 'Fri']) {
    await tapText(tester, day);
  }
  await tapText(tester, 'Continue');
  await answerSingle(tester, 'Morning');
  await answerSingle(tester, '20 minutes');
  await answerSingle(tester, 'Outdoor park');
  await answerSingle(tester, 'Gentle reminders');
  await answerSingle(tester, "No, I'm ready to start");
  await tapText(tester, 'None of these');
  await tapText(tester, 'Continue');
  await answerSingle(tester, 'Balanced beginner plan');
}

Future<void> completeOnboardingToFourSessionPreview(WidgetTester tester) async {
  await tapText(tester, 'Start setup');
  await answerSingle(tester, 'Work toward a 10K');
  await answerSingle(tester, 'I can run 20-30 minutes');
  await answerSingle(tester, '4 days per week');
  for (final day in ['Mon', 'Tue', 'Wed', 'Thu']) {
    await tapText(tester, day);
  }
  await tapText(tester, 'Continue');
  await answerSingle(tester, 'Morning');
  await answerSingle(tester, '30 minutes');
  await answerSingle(tester, 'Outdoor park');
  await answerSingle(tester, 'Gentle reminders');
  await answerSingle(tester, "No, I'm ready to start");
  await tapText(tester, 'None of these');
  await tapText(tester, 'Continue');
  await answerSingle(tester, 'Standard beginner plan');
}

Future<void> advanceToPreferredDays(
  WidgetTester tester,
  String availabilityLabel,
) async {
  await tapText(tester, 'Start setup');
  await answerSingle(tester, 'Build a running habit');
  await answerSingle(tester, 'Completely new to running');
  await answerSingle(tester, availabilityLabel);
}

Future<void> advanceToSymptoms(WidgetTester tester) async {
  await tapText(tester, 'Start setup');
  await answerSingle(tester, 'Build a running habit');
  await answerSingle(tester, 'Completely new to running');
  await answerSingle(tester, '3 days per week');
  for (final day in ['Mon', 'Wed', 'Fri']) {
    await tapText(tester, day);
  }
  await tapText(tester, 'Continue');
  await answerSingle(tester, 'Morning');
  await answerSingle(tester, '20 minutes');
  await answerSingle(tester, 'Outdoor park');
  await answerSingle(tester, 'Gentle reminders');
  await answerSingle(tester, "No, I'm ready to start");
  expect(find.text('Step 11 of 13'), findsOneWidget);
}

Future<void> answerSingle(WidgetTester tester, String option) async {
  await tapText(tester, option);
  await tapText(tester, 'Continue');
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).first;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> tapTooltip(WidgetTester tester, String tooltip) async {
  final finder = find.byTooltip(tooltip).first;
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

FilledButton primaryContinueButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Continue').last,
  );
}
