class PlanProgressReadModel {
  PlanProgressReadModel({
    required Iterable<String> completedScheduledWorkoutIds,
  }) : completedScheduledWorkoutIds = Set.unmodifiable(
         completedScheduledWorkoutIds,
       );

  factory PlanProgressReadModel.empty() {
    return PlanProgressReadModel(completedScheduledWorkoutIds: const []);
  }

  factory PlanProgressReadModel.fromBackend({
    required String activeGeneratedPlanId,
    required Map<String, Object?>? data,
  }) {
    if (data == null || activeGeneratedPlanId.isEmpty) {
      return PlanProgressReadModel.empty();
    }

    final workouts = data['workouts'];
    if (workouts is! Map) {
      return PlanProgressReadModel.empty();
    }

    final completedIds = <String>{};
    for (final entry in workouts.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! Map || value['completedAt'] == null) {
        continue;
      }
      if (key != key.trim()) {
        continue;
      }
      final scheduledWorkoutId = _activeScheduledWorkoutId(
        key,
        activeGeneratedPlanId: activeGeneratedPlanId,
      );
      if (scheduledWorkoutId != null) {
        completedIds.add(scheduledWorkoutId);
      }
    }

    return PlanProgressReadModel(completedScheduledWorkoutIds: completedIds);
  }

  final Set<String> completedScheduledWorkoutIds;
}

String? _activeScheduledWorkoutId(
  String key, {
  required String activeGeneratedPlanId,
}) {
  final separatorIndex = key.indexOf('__');
  if (separatorIndex <= 0 || separatorIndex != key.lastIndexOf('__')) {
    return null;
  }

  final generatedPlanId = key.substring(0, separatorIndex);
  final scheduledWorkoutId = key.substring(separatorIndex + 2);
  if (generatedPlanId != activeGeneratedPlanId ||
      scheduledWorkoutId.isEmpty ||
      scheduledWorkoutId != scheduledWorkoutId.trim()) {
    return null;
  }
  return scheduledWorkoutId;
}
