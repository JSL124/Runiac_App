class ExpertPlansReadModel {
  ExpertPlansReadModel({
    required List<ExpertPlanReadModel> plans,
    List<String> filters = const <String>[],
    this.featuredPlan,
  }) : plans = List.unmodifiable(plans),
       filters = List.unmodifiable(filters);

  final List<ExpertPlanReadModel> plans;
  final List<String> filters;
  final ExpertPlanDetailReadModel? featuredPlan;
}

class ExpertPlanReadModel {
  const ExpertPlanReadModel({
    required this.planId,
    required this.title,
    required this.authorLabel,
    required this.publicationStatusLabel,
    this.description = '',
    this.durationLabel = '',
    this.frequencyLabel = '',
    this.levelLabel = '',
  });

  final String planId;
  final String title;
  final String authorLabel;
  final String publicationStatusLabel;
  final String description;
  final String durationLabel;
  final String frequencyLabel;
  final String levelLabel;
}

class ExpertPlanDetailReadModel {
  ExpertPlanDetailReadModel({
    required this.planId,
    required this.title,
    required this.subtitle,
    required this.durationLabel,
    required this.frequencyLabel,
    required this.levelLabel,
    required this.pressureLabel,
    required this.coachInsight,
    required List<ExpertPlanWeekReadModel> weeklyPreview,
    required this.publicationStatusLabel,
  }) : weeklyPreview = List.unmodifiable(weeklyPreview);

  final String planId;
  final String title;
  final String subtitle;
  final String durationLabel;
  final String frequencyLabel;
  final String levelLabel;
  final String pressureLabel;
  final String coachInsight;
  final List<ExpertPlanWeekReadModel> weeklyPreview;
  final String publicationStatusLabel;
}

class ExpertPlanWeekReadModel {
  ExpertPlanWeekReadModel({
    required this.weekLabel,
    required this.title,
    required List<String> bullets,
  }) : bullets = List.unmodifiable(bullets);

  final String weekLabel;
  final String title;
  final List<String> bullets;
}
