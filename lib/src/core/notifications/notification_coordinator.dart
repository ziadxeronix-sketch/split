import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/budget/data/budget_repository.dart';
import '../../features/budget/presentation/budget_providers.dart';
import '../../features/transactions/data/transactions_repository.dart';
import '../../features/transactions/presentation/transactions_providers.dart';
import '../date_utils.dart';
import 'notification_preferences.dart';
import 'notification_preferences_service.dart';
import 'notification_providers.dart';
import 'notifications_service.dart';

final notificationCoordinatorProvider = Provider<NotificationCoordinator>((ref) {
  return NotificationCoordinator(
    transactions: ref.watch(transactionsRepositoryProvider),
    budgets: ref.watch(budgetRepositoryProvider),
    preferencesService: ref.watch(notificationPreferencesServiceProvider),
  );
});

class NotificationCoordinator {
  NotificationCoordinator({
    required this.transactions,
    required this.budgets,
    required this.preferencesService,
  });

  final TransactionsRepository transactions;
  final BudgetRepository budgets;
  final NotificationPreferencesService preferencesService;

  Future<void> bootstrap() async {
    // Notifications disabled: keep UI but do nothing.
  }

  Future<bool> requestPermissionAndSync() async {
    // Notifications disabled: pretend permission denied without doing anything.
    return false;
  }

  Future<void> savePreferences(NotificationPreferences prefs) async {
    // Persist user choices locally for UI, but don't schedule real notifications.
    await preferencesService.save(prefs);
  }

  Future<void> evaluateAfterExpenseAdded({required double latestAmount, required String categoryId}) async {
    // Notifications disabled: no-op.
  }

  Future<void> checkInactivity() async {
    // Notifications disabled: no-op.
  }

  Future<void> _syncReminder(NotificationPreferences prefs) async {
    // Notifications disabled: do not schedule or cancel OS notifications.
  }
}
