import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_history_service.dart';
import 'notification_model.dart';

class NotificationsService {
  NotificationsService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final NotificationHistoryService _historyService = NotificationHistoryService();

  static const int dailyReminderId = 2101;
  static const int budgetNearId = 2102;
  static const int budgetExceededId = 2103;
  static const int overspendingId = 2104;
  static const int inactivityId = 2105;
  static const int fcmNotificationId = 2106;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
    } catch (_) {
      // Safe to continue if timezones were already initialized.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    try {
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'budget_alerts',
          'Budget alerts',
          description: 'Alerts for budget thresholds and overspending.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'habit_alerts',
          'Habit alerts',
          description: 'Reminders for inactivity and daily logging habits.',
          importance: Importance.high,
          playSound: true,
        ),
      );
    } catch (error, stack) {
      debugPrint('Notification channel setup failed: $error');
      debugPrintStack(stackTrace: stack);
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification == null) return;
          _show(
            id: fcmNotificationId,
            channelId: 'budget_alerts',
            channelName: 'System Alerts',
            title: notification.title ?? 'New Alert',
            body: notification.body ?? '',
            category: 'info',
          );
        });
      }
    } catch (error, stack) {
      debugPrint('FirebaseMessaging foreground listener failed: $error');
      debugPrintStack(stackTrace: stack);
    }

    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    try {
      if (!_initialized) await init();

      bool granted = true;

      try {
        if (Firebase.apps.isNotEmpty) {
          final messaging = FirebaseMessaging.instance;
          final settings = await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );
          granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
        }
      } catch (error, stack) {
        debugPrint('FCM permission request failed: $error');
        debugPrintStack(stackTrace: stack);
      }

      try {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final androidGranted = await androidPlugin?.requestNotificationsPermission();
        if (androidGranted != null) {
          granted = granted && androidGranted;
        }
      } catch (error, stack) {
        debugPrint('Local notification permission request failed: $error');
        debugPrintStack(stackTrace: stack);
      }

      return granted;
    } catch (error, stack) {
      debugPrint('Notifications permission flow failed: $error');
      debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<void> showBudgetWarning({
    required String title,
    required String body,
    bool exceeded = false,
  }) async {
    final category = exceeded ? 'budget_exceeded' : 'budget_near';
    await _show(
      id: exceeded ? budgetExceededId : budgetNearId,
      channelId: 'budget_alerts',
      channelName: 'Budget alerts',
      title: title,
      body: body,
      category: category,
    );
  }

  static Future<void> showOverspending({
    required String title,
    required String body,
  }) async {
    await _show(
      id: overspendingId,
      channelId: 'budget_alerts',
      channelName: 'Budget alerts',
      title: title,
      body: body,
      category: 'overspending',
    );
  }

  static Future<void> showInactivity({
    required String title,
    required String body,
  }) async {
    await _show(
      id: inactivityId,
      channelId: 'habit_alerts',
      channelName: 'Habit alerts',
      title: title,
      body: body,
      category: 'habit',
    );
  }

  static Future<void> scheduleDailyReminder({required int hour}) async {
    if (!_initialized) await init();
    await cancelDailyReminder();

    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (error, stack) {
      debugPrint('Exact alarms permission request failed: $error');
      debugPrintStack(stackTrace: stack);
    }

    await _plugin.zonedSchedule(
      dailyReminderId,
      'Budget check-in',
      'Open SplitBrain and log today\'s spending to keep your budget fresh.',
      _nextInstanceOfHour(hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_alerts',
          'Habit alerts',
          channelDescription: 'Reminders for inactivity and daily logging habits.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    if (!_initialized) await init();
    await _plugin.cancel(dailyReminderId);
  }

  static tz.TZDateTime _nextInstanceOfHour(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    final normalizedHour = hour.clamp(0, 23);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      normalizedHour,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<void> _show({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    String category = 'info',
  }) async {
    if (!_initialized) await init();

    try {
      await _historyService.addNotification(
        AppNotification(
          title: title,
          body: body,
          timestamp: DateTime.now(),
          category: category,
        ),
      );
    } catch (error, stack) {
      debugPrint('Saving notification history failed: $error');
      debugPrintStack(stackTrace: stack);
    }

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }
}
