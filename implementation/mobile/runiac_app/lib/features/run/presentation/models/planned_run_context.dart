class PlannedRunContext {
  const PlannedRunContext({
    required this.title,
    required this.durationMinutes,
    required this.planTitle,
    required this.planFamilyLabel,
    required this.workoutKindLabel,
    required this.intensityLabel,
    required this.steps,
    required this.supportiveNote,
    required this.sourceLabel,
  });

  final String title;
  final int durationMinutes;
  final String planTitle;
  final String planFamilyLabel;
  final String workoutKindLabel;
  final String intensityLabel;
  final List<String> steps;
  final String supportiveNote;
  final String sourceLabel;

  String get durationLabel => '$durationMinutes min';
}
