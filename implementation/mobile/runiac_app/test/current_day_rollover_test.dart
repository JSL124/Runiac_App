import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/shell/current_day_rollover.dart';

void main() {
  test('refresh advances the shell date after local midnight', () {
    var now = DateTime(2026, 7, 10, 23, 59);
    final controller = CurrentDayRolloverController(now: () => now);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications += 1);

    expect(controller.today, DateTime(2026, 7, 10));

    now = DateTime(2026, 7, 11);
    controller.refresh();

    expect(controller.today, DateTime(2026, 7, 11));
    expect(notifications, 1);
  });

  test('next refresh delay targets the next local midnight', () {
    expect(
      nextLocalDayRefreshDelay(DateTime(2026, 7, 10, 23, 59, 30)),
      const Duration(seconds: 30),
    );
  });
}
