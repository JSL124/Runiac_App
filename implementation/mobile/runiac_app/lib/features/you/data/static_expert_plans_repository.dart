import '../domain/models/expert_plans_read_model.dart';
import '../domain/repositories/expert_plans_repository.dart';
import '../presentation/data/expert_plan_demo_snapshots.dart';

class StaticExpertPlansRepository implements ExpertPlansRepository {
  @override
  Future<ExpertPlansReadModel> loadExpertPlans() async {
    return ExpertPlansReadModel(
      filters: expertPlanFilters,
      plans: expertPlans
          .map(
            (plan) => ExpertPlanReadModel(
              planId: _planIdForTitle(plan.title),
              title: plan.title,
              authorLabel: plan.reviewer,
              publicationStatusLabel: 'Approved',
              description: plan.description,
              durationLabel: plan.duration,
              frequencyLabel: plan.frequency,
              levelLabel: plan.level,
            ),
          )
          .toList(growable: false),
      featuredPlan: ExpertPlanDetailReadModel(
        planId: _planIdForTitle(expertPlanDetailSnapshot.title),
        title: expertPlanDetailSnapshot.title,
        subtitle: expertPlanDetailSnapshot.subtitle,
        durationLabel: expertPlanDetailSnapshot.duration,
        frequencyLabel: expertPlanDetailSnapshot.frequency,
        levelLabel: expertPlanDetailSnapshot.level,
        pressureLabel: expertPlanDetailSnapshot.pressure,
        coachInsight: expertPlanDetailSnapshot.coachInsight,
        publicationStatusLabel: 'Approved',
        weeklyPreview: expertPlanDetailSnapshot.weeklyPreview
            .map(
              (week) => ExpertPlanWeekReadModel(
                weekLabel: week.weekLabel,
                title: week.title,
                bullets: week.bullets,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

String _planIdForTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
