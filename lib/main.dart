import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/notifications/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
  };

  await runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      // Allow the app to boot even if Firebase setup is temporarily broken.
      // Screens that depend on Firebase can still show their own error states.
    }

    unawaited(_safeInitNotifications());

    runApp(const ProviderScope(child: SplitBrainApp()));
  }, (error, stack) {
    debugPrint('Unhandled startup error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

Future<void> _safeInitNotifications() async {
  try {
    await NotificationsService.init();
  } catch (error, stack) {
    debugPrint('Notifications init failed: $error');
    debugPrintStack(stackTrace: stack);
  }
}
