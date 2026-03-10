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
    await NotificationsService.init();
    final prefs = await preferencesService.load();
    await _syncReminder(prefs);
  }

  Future<bool> requestPermissionAndSync() async {
    final granted = await NotificationsService.requestPermissions();
    final prefs = await preferencesService.load();
    await _syncReminder(prefs);
    return granted;
  }

  Future<void> savePreferences(NotificationPreferences prefs) async {
    await preferencesService.save(prefs);
    await _syncReminder(prefs);
  }

  Future<void> evaluateAfterExpenseAdded({required double latestAmount, required String categoryId}) async {
    final prefs = await preferencesService.load();
    if (!prefs.enabled) return;

    final now = DateTime.now();
    final todayKey = dayKey(now);
    final budget = await budgets.getActiveOnce();

    if (budget != null && budget.amount > 0) {
      final todaySpent = await transactions.sumRangeOnce(start: startOfDay(now), end: endOfDay(now));
      final dailyBudget = budget.period.name == 'weekly'
          ? budget.amount / 7.0
          : budget.amount / daysInMonth(now).toDouble();
      final remaining = dailyBudget - todaySpent;

      if (prefs.budgetAlerts && dailyBudget > 0) {
        if (remaining <= 0) {
          final sent = await preferencesService.readMarker(NotificationPreferencesService.lastBudgetExceededKey);
          if (sent != todayKey) {
            await NotificationsService.showBudgetWarning(
              exceeded: true,
              title: 'Budget limit reached',
              body: 'You have passed today\'s spending target. Slow the next purchase down a bit.',
            );
            await preferencesService.writeMarker(NotificationPreferencesService.lastBudgetExceededKey, todayKey);
          }
        } else if (todaySpent >= dailyBudget * 0.8) {
          final sent = await preferencesService.readMarker(NotificationPreferencesService.lastBudgetNearKey);
          if (sent != todayKey) {
            await NotificationsService.showBudgetWarning(
              title: 'You are close to today\'s limit',
              body: 'About ${(todaySpent / dailyBudget * 100).round()}% of the daily budget is already used.',
            );
            await preferencesService.writeMarker(NotificationPreferencesService.lastBudgetNearKey, todayKey);
          }
        }
      }

      if (prefs.overspendingAlerts) {
        final sevenDaysAgo = startOfDay(now.subtract(const Duration(days: 7)));
        final yesterdayEnd = endOfDay(now.subtract(const Duration(days: 1)));
        final recent = await transactions.listRangeOnce(start: sevenDaysAgo, end: yesterdayEnd);
        double historicalTotal = 0;
        for (final tx in recent) {
          historicalTotal += tx.amount;
        }
        final baseline = recent.isEmpty ? dailyBudget : (historicalTotal / 7.0);
        final todayList = await transactions.listRangeOnce(start: startOfDay(now), end: endOfDay(now));
        final categoryToday = todayList
            .where((tx) => tx.categoryId == categoryId)
            .fold<double>(0, (sum, tx) => sum + tx.amount);

        final categorySpike = categoryToday >= latestAmount * 1.2 && latestAmount >= (dailyBudget * 0.3);
        final totalSpike = todaySpent >= (baseline * 1.55) && todaySpent >= dailyBudget * 0.9;

        final sent = await preferencesService.readMarker(NotificationPreferencesService.lastOverspendingKey);
        if ((categorySpike || totalSpike) && sent != todayKey) {
          await NotificationsService.showOverspending(
            title: 'Overspending pattern detected',
            body: categorySpike
                ? 'Spending in this category spiked today. Double-check if it fits your plan.'
                : 'Today is trending well above your recent daily average. Consider slowing down the rest of the day.',
          );
          await preferencesService.writeMarker(NotificationPreferencesService.lastOverspendingKey, todayKey);
        }
      }
    }

    await checkInactivity();
  }

  Future<void> checkInactivity() async {
    final prefs = await preferencesService.load();
    if (!prefs.enabled || !prefs.inactivityAlerts) return;

    final now = DateTime.now();
    final todayKey = dayKey(now);
    final lastExpenseAt = await transactions.latestExpenseAt();

    if (lastExpenseAt == null) {
      final sent = await preferencesService.readMarker(NotificationPreferencesService.lastInactivityKey);
      if (sent != todayKey) {
        await NotificationsService.showInactivity(
          title: 'Start your money streak',
          body: 'Log your first expense today so your dashboard and insights can work for you.',
        );
        await preferencesService.writeMarker(NotificationPreferencesService.lastInactivityKey, todayKey);
      }
      return;
    }

    final idleDays = startOfDay(now).difference(startOfDay(lastExpenseAt)).inDays;
    if (idleDays >= prefs.inactivityDays) {
      final sent = await preferencesService.readMarker(NotificationPreferencesService.lastInactivityKey);
      if (sent != todayKey) {
        await NotificationsService.showInactivity(
          title: 'No expense logged in a while',
          body: 'It has been $idleDays day${idleDays == 1 ? '' : 's'} since the last entry. Add today\'s spend to stay consistent.',
        );
        await preferencesService.writeMarker(NotificationPreferencesService.lastInactivityKey, todayKey);
      }
    }
  }

  Future<void> _syncReminder(NotificationPreferences prefs) async {
    if (!prefs.enabled || !prefs.dailyReminder) {
      await NotificationsService.cancelDailyReminder();
      return;
    }
    await NotificationsService.scheduleDailyReminder(hour: prefs.reminderHour);
  }
}
