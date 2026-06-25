enum OnboardingGoal {
  habit('habit'),
  gentle('gentle'),
  first5k('5k'),
  tenK('10k'),
  stamina('stamina');

  const OnboardingGoal(this.value);

  final String value;

  static OnboardingGoal? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingExperience {
  newRunner('new'),
  walk('walk'),
  intervals('intervals'),
  run10('run10'),
  run30('run30');

  const OnboardingExperience(this.value);

  final String value;

  static OnboardingExperience? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingAvailability {
  two('2'),
  three('3'),
  four('4'),
  unsure('unsure');

  const OnboardingAvailability(this.value);

  final String value;

  static OnboardingAvailability? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingPreferredDay {
  mon('Mon'),
  tue('Tue'),
  wed('Wed'),
  thu('Thu'),
  fri('Fri'),
  sat('Sat'),
  sun('Sun');

  const OnboardingPreferredDay(this.value);

  final String value;

  static OnboardingPreferredDay? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingPreferredTime {
  morning('morning'),
  afternoon('afternoon'),
  evening('evening'),
  night('night'),
  flexible('flexible');

  const OnboardingPreferredTime(this.value);

  final String value;

  static OnboardingPreferredTime? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingSessionLength {
  fifteen('15'),
  twenty('20'),
  thirty('30'),
  fortyFive('45'),
  unsure('unsure');

  const OnboardingSessionLength(this.value);

  final String value;

  static OnboardingSessionLength? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingRunningPlace {
  park('park'),
  road('road'),
  track('track'),
  treadmill('treadmill'),
  mixed('mixed');

  const OnboardingRunningPlace(this.value);

  final String value;

  static OnboardingRunningPlace? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingMotivationStyle {
  reminders('reminders'),
  plan('plan'),
  encourage('encourage'),
  challenge('challenge'),
  expert('expert');

  const OnboardingMotivationStyle(this.value);

  final String value;

  static OnboardingMotivationStyle? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingHealthComfort {
  ready('ready'),
  breakAfterTimeAway('break'),
  injury('injury'),
  heart('heart'),
  asthma('asthma'),
  joint('joint'),
  advised('advised'),
  unsure('unsure');

  const OnboardingHealthComfort(this.value);

  final String value;

  static OnboardingHealthComfort? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingActivitySymptom {
  chest('chest'),
  dizzy('dizzy'),
  breath('breath'),
  heartbeat('heartbeat'),
  legpain('legpain'),
  none('none');

  const OnboardingActivitySymptom(this.value);

  final String value;

  static OnboardingActivitySymptom? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

enum OnboardingPlanCautiousness {
  veryGentle('verygentle'),
  balanced('balanced'),
  standard('standard'),
  unsure('unsure');

  const OnboardingPlanCautiousness(this.value);

  final String value;

  static OnboardingPlanCautiousness? fromValue(String? value) =>
      _enumByValue(values, value, (item) => item.value);
}

T? _enumByValue<T extends Enum>(
  List<T> values,
  String? value,
  String Function(T item) itemValue,
) {
  for (final item in values) {
    if (itemValue(item) == value) {
      return item;
    }
  }
  return null;
}
