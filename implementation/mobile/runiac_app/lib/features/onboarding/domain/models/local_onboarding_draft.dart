import 'onboarding_answer_enums.dart';

export 'onboarding_answer_enums.dart';

class LocalOnboardingDraft {
  LocalOnboardingDraft({
    required this.goal,
    required this.experience,
    required this.availability,
    required List<OnboardingPreferredDay> preferredDays,
    required this.preferredTime,
    required this.sessionLength,
    required this.runningPlace,
    required this.motivationStyle,
    required this.healthComfort,
    required List<OnboardingActivitySymptom> activitySymptoms,
    required this.planCautiousness,
  }) : preferredDays = List.unmodifiable(preferredDays),
       activitySymptoms = List.unmodifiable(
         _normalizeSymptoms(activitySymptoms),
       );

  final OnboardingGoal goal;
  final OnboardingExperience experience;
  final OnboardingAvailability availability;
  final List<OnboardingPreferredDay> preferredDays;
  final OnboardingPreferredTime preferredTime;
  final OnboardingSessionLength sessionLength;
  final OnboardingRunningPlace runningPlace;
  final OnboardingMotivationStyle motivationStyle;
  final OnboardingHealthComfort healthComfort;
  final List<OnboardingActivitySymptom> activitySymptoms;
  final OnboardingPlanCautiousness planCautiousness;

  static LocalOnboardingDraft? fromAnswers(Map<String, Object> answers) {
    final goal = OnboardingGoal.fromValue(_stringAnswer(answers, 'goal'));
    final experience = OnboardingExperience.fromValue(
      _stringAnswer(answers, 'experience'),
    );
    final availability = OnboardingAvailability.fromValue(
      _stringAnswer(answers, 'availability'),
    );
    final preferredTime = OnboardingPreferredTime.fromValue(
      _stringAnswer(answers, 'time'),
    );
    final sessionLength = OnboardingSessionLength.fromValue(
      _stringAnswer(answers, 'length'),
    );
    final runningPlace = OnboardingRunningPlace.fromValue(
      _stringAnswer(answers, 'place'),
    );
    final motivationStyle = OnboardingMotivationStyle.fromValue(
      _stringAnswer(answers, 'motivation'),
    );
    final healthComfort = OnboardingHealthComfort.fromValue(
      _stringAnswer(answers, 'health'),
    );
    final planCautiousness = OnboardingPlanCautiousness.fromValue(
      _stringAnswer(answers, 'cautious'),
    );

    if (goal == null ||
        experience == null ||
        availability == null ||
        preferredTime == null ||
        sessionLength == null ||
        runningPlace == null ||
        motivationStyle == null ||
        healthComfort == null ||
        planCautiousness == null) {
      return null;
    }

    return LocalOnboardingDraft(
      goal: goal,
      experience: experience,
      availability: availability,
      preferredDays: _enumListAnswer(
        answers,
        'days',
        OnboardingPreferredDay.fromValue,
      ),
      preferredTime: preferredTime,
      sessionLength: sessionLength,
      runningPlace: runningPlace,
      motivationStyle: motivationStyle,
      healthComfort: healthComfort,
      activitySymptoms: _enumListAnswer(
        answers,
        'symptoms',
        OnboardingActivitySymptom.fromValue,
      ),
      planCautiousness: planCautiousness,
    );
  }

  bool get hasCautionIntent {
    return activitySymptoms.isEmpty ||
        planCautiousness == OnboardingPlanCautiousness.veryGentle ||
        planCautiousness == OnboardingPlanCautiousness.unsure ||
        healthComfort != OnboardingHealthComfort.ready ||
        activitySymptoms.any(
          (symptom) => symptom != OnboardingActivitySymptom.none,
        );
  }

  int get requestedWeeklySessionCount {
    return switch (availability) {
      OnboardingAvailability.two => 2,
      OnboardingAvailability.three => 3,
      OnboardingAvailability.four => 4,
      OnboardingAvailability.unsure => 2,
    };
  }

  int get preferredDurationMinutes {
    return switch (sessionLength) {
      OnboardingSessionLength.fifteen => 15,
      OnboardingSessionLength.twenty => 20,
      OnboardingSessionLength.thirty => 30,
      OnboardingSessionLength.fortyFive => 45,
      OnboardingSessionLength.unsure => 15,
    };
  }
}

String? _stringAnswer(Map<String, Object> answers, String key) {
  final value = answers[key];
  return value is String ? value : null;
}

List<T> _enumListAnswer<T extends Enum>(
  Map<String, Object> answers,
  String key,
  T? Function(String? value) fromValue,
) {
  final raw = answers[key];
  final values = raw is Set<String>
      ? raw
      : raw is Iterable<String>
      ? raw
      : const <String>[];
  return values.map(fromValue).nonNulls.toList(growable: false);
}

List<OnboardingActivitySymptom> _normalizeSymptoms(
  List<OnboardingActivitySymptom> symptoms,
) {
  if (symptoms.length == 1 &&
      symptoms.contains(OnboardingActivitySymptom.none)) {
    return const <OnboardingActivitySymptom>[OnboardingActivitySymptom.none];
  }
  return symptoms
      .where((symptom) => symptom != OnboardingActivitySymptom.none)
      .toList(growable: false);
}
