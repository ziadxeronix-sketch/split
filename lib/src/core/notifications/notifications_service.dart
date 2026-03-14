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
    // Disabled: do not show OS notifications but keep history empty as well.
  }

  static Future<void> showOverspending({
    required String title,
    required String body,
  }) async {
    // Disabled.
  }

  static Future<void> showInactivity({
    required String title,
    required String body,
  }) async {
    // Disabled.
  }

  static Future<void> scheduleDailyReminder({required int hour}) async {
    // Disabled: do not schedule local notifications.
  }

  static Future<void> cancelDailyReminder() async {
    // Disabled: nothing to cancel.
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
    // Disabled: do not record or show notifications.
  }
}
