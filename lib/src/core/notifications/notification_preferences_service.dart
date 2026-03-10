import 'package:shared_preferences/shared_preferences.dart';

import 'notification_preferences.dart';

class NotificationPreferencesService {
  static const _enabled = 'notifications.enabled';
  static const _budgetAlerts = 'notifications.budgetAlerts';
  static const _overspendingAlerts = 'notifications.overspendingAlerts';
  static const _inactivityAlerts = 'notifications.inactivityAlerts';
  static const _dailyReminder = 'notifications.dailyReminder';
  static const _reminderHour = 'notifications.reminderHour';
  static const _inactivityDays = 'notifications.inactivityDays';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      enabled: prefs.getBool(_enabled) ?? NotificationPreferences.defaults.enabled,
      budgetAlerts: prefs.getBool(_budgetAlerts) ?? NotificationPreferences.defaults.budgetAlerts,
      overspendingAlerts: prefs.getBool(_overspendingAlerts) ?? NotificationPreferences.defaults.overspendingAlerts,
      inactivityAlerts: prefs.getBool(_inactivityAlerts) ?? NotificationPreferences.defaults.inactivityAlerts,
      dailyReminder: prefs.getBool(_dailyReminder) ?? NotificationPreferences.defaults.dailyReminder,
      reminderHour: prefs.getInt(_reminderHour) ?? NotificationPreferences.defaults.reminderHour,
      inactivityDays: prefs.getInt(_inactivityDays) ?? NotificationPreferences.defaults.inactivityDays,
    );
  }

  Future<void> save(NotificationPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabled, value.enabled);
    await prefs.setBool(_budgetAlerts, value.budgetAlerts);
    await prefs.setBool(_overspendingAlerts, value.overspendingAlerts);
    await prefs.setBool(_inactivityAlerts, value.inactivityAlerts);
    await prefs.setBool(_dailyReminder, value.dailyReminder);
    await prefs.setInt(_reminderHour, value.reminderHour.clamp(0, 23));
    await prefs.setInt(_inactivityDays, value.inactivityDays.clamp(1, 14));
  }

  Future<void> saveField(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (value) {
      case bool b:
        await prefs.setBool(key, b);
      case int i:
        await prefs.setInt(key, i);
      case String s:
        await prefs.setString(key, s);
      default:
        throw UnsupportedError('Unsupported preference type: ${value.runtimeType}');
    }
  }

  static const lastBudgetNearKey = 'notifications.lastBudgetNear';
  static const lastBudgetExceededKey = 'notifications.lastBudgetExceeded';
  static const lastOverspendingKey = 'notifications.lastOverspending';
  static const lastInactivityKey = 'notifications.lastInactivity';

  Future<String?> readMarker(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> writeMarker(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
