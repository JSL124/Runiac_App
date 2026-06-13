import '../models/expert_plans_read_model.dart';

abstract interface class ExpertPlansRepository {
  Future<ExpertPlansReadModel> loadExpertPlans();
}
