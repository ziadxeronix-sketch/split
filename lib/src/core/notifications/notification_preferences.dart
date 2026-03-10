class NotificationPreferences {
  const NotificationPreferences({
    required this.enabled,
    required this.budgetAlerts,
    required this.overspendingAlerts,
    required this.inactivityAlerts,
    required this.dailyReminder,
    required this.reminderHour,
    required this.inactivityDays,
  });

  final bool enabled;
  final bool budgetAlerts;
  final bool overspendingAlerts;
  final bool inactivityAlerts;
  final bool dailyReminder;
  final int reminderHour;
  final int inactivityDays;

  static const defaults = NotificationPreferences(
    enabled: true,
    budgetAlerts: true,
    overspendingAlerts: true,
    inactivityAlerts: true,
    dailyReminder: true,
    reminderHour: 20,
    inactivityDays: 2,
  );

  NotificationPreferences copyWith({
    bool? enabled,
    bool? budgetAlerts,
    bool? overspendingAlerts,
    bool? inactivityAlerts,
    bool? dailyReminder,
    int? reminderHour,
    int? inactivityDays,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      overspendingAlerts: overspendingAlerts ?? this.overspendingAlerts,
      inactivityAlerts: inactivityAlerts ?? this.inactivityAlerts,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderHour: reminderHour ?? this.reminderHour,
      inactivityDays: inactivityDays ?? this.inactivityDays,
    );
  }
}
