import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_preferences.dart';
import 'notification_preferences_service.dart';
import 'notification_history_service.dart';
import 'notification_model.dart';

final notificationPreferencesServiceProvider = Provider<NotificationPreferencesService>((ref) {
  return NotificationPreferencesService();
});

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>((ref) async {
  return ref.watch(notificationPreferencesServiceProvider).load();
});

final notificationHistoryServiceProvider = Provider<NotificationHistoryService>((ref) {
  return NotificationHistoryService();
});

final notificationHistoryProvider = FutureProvider<List<AppNotification>>((ref) async {
  return ref.watch(notificationHistoryServiceProvider).getHistory();
});

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  final history = await ref.watch(notificationHistoryServiceProvider).getHistory();
  return history.where((n) => !n.isRead).length;
});
