enum NotificationPreference {
  planStartReminder,
  todaysPlanReminder,
  missedRunNudge,
  planUpdates,
}

class NotificationCenterSettings {
  const NotificationCenterSettings({
    required this.notificationsEnabled,
    required this.planStartReminderEnabled,
    required this.todaysPlanReminderEnabled,
    required this.missedRunNudgeEnabled,
    required this.planUpdatesEnabled,
  });

  static const defaults = NotificationCenterSettings(
    notificationsEnabled: true,
    planStartReminderEnabled: true,
    todaysPlanReminderEnabled: true,
    missedRunNudgeEnabled: true,
    planUpdatesEnabled: true,
  );

  final bool notificationsEnabled;
  final bool planStartReminderEnabled;
  final bool todaysPlanReminderEnabled;
  final bool missedRunNudgeEnabled;
  final bool planUpdatesEnabled;

  int get enabledPreferenceCount {
    return [
      planStartReminderEnabled,
      todaysPlanReminderEnabled,
      missedRunNudgeEnabled,
      planUpdatesEnabled,
    ].where((enabled) => enabled).length;
  }

  bool isPreferenceEnabled(NotificationPreference preference) {
    return switch (preference) {
      NotificationPreference.planStartReminder => planStartReminderEnabled,
      NotificationPreference.todaysPlanReminder => todaysPlanReminderEnabled,
      NotificationPreference.missedRunNudge => missedRunNudgeEnabled,
      NotificationPreference.planUpdates => planUpdatesEnabled,
    };
  }

  NotificationCenterSettings copyWith({
    bool? notificationsEnabled,
    bool? planStartReminderEnabled,
    bool? todaysPlanReminderEnabled,
    bool? missedRunNudgeEnabled,
    bool? planUpdatesEnabled,
  }) {
    return NotificationCenterSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      planStartReminderEnabled:
          planStartReminderEnabled ?? this.planStartReminderEnabled,
      todaysPlanReminderEnabled:
          todaysPlanReminderEnabled ?? this.todaysPlanReminderEnabled,
      missedRunNudgeEnabled:
          missedRunNudgeEnabled ?? this.missedRunNudgeEnabled,
      planUpdatesEnabled: planUpdatesEnabled ?? this.planUpdatesEnabled,
    );
  }

  NotificationCenterSettings withPreference(
    NotificationPreference preference,
    bool enabled,
  ) {
    return switch (preference) {
      NotificationPreference.planStartReminder => copyWith(
        planStartReminderEnabled: enabled,
      ),
      NotificationPreference.todaysPlanReminder => copyWith(
        todaysPlanReminderEnabled: enabled,
      ),
      NotificationPreference.missedRunNudge => copyWith(
        missedRunNudgeEnabled: enabled,
      ),
      NotificationPreference.planUpdates => copyWith(
        planUpdatesEnabled: enabled,
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationCenterSettings &&
        other.notificationsEnabled == notificationsEnabled &&
        other.planStartReminderEnabled == planStartReminderEnabled &&
        other.todaysPlanReminderEnabled == todaysPlanReminderEnabled &&
        other.missedRunNudgeEnabled == missedRunNudgeEnabled &&
        other.planUpdatesEnabled == planUpdatesEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      planStartReminderEnabled,
      todaysPlanReminderEnabled,
      missedRunNudgeEnabled,
      planUpdatesEnabled,
    );
  }
}
