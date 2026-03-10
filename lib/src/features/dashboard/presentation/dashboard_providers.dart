import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/date_utils.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../transactions/presentation/transactions_providers.dart';

enum DashboardRange { today, week, month }

class DashboardSummary {
  const DashboardSummary({
    required this.range,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currency,
  });

  final DashboardRange range;
  final double budget;
  final double spent;
  final double remaining;
  final double progress;
  final String currency;
}

final dashboardRangeProvider =
StateProvider.autoDispose<DashboardRange>((ref) => DashboardRange.today);

final dashboardSummaryProvider =
StreamProvider.autoDispose<DashboardSummary>((ref) {
  final range = ref.watch(dashboardRangeProvider);
  final budgetAsync = ref.watch(activeBudgetProvider);

  if (budgetAsync.isLoading) {
    return const Stream.empty();
  }

  final b = budgetAsync.value;
  final now = DateTime.now();

  if (b == null || b.amount <= 0) {
    final summary = DashboardSummary(
      range: range,
      budget: 0,
      spent: 0,
      remaining: 0,
      progress: 0,
      currency: '€',
    );
    return Stream.value(summary);
  }

  DateTime start;
  DateTime end;

  switch (range) {
    case DashboardRange.today:
      start = startOfDay(now);
      end = endOfDay(now);
      break;
    case DashboardRange.week:
      start = startOfWeek(now);
      end = endOfWeek(now);
      break;
    case DashboardRange.month:
      start = startOfMonth(now);
      end = endOfMonth(now);
      break;
  }

  final dailyBudget = b.period.name == 'weekly'
      ? (b.amount / 7.0)
      : (b.amount / daysInMonth(now).toDouble());

  final rangeBudget = switch (range) {
    DashboardRange.today => dailyBudget,
    DashboardRange.week => dailyBudget * 7,
    DashboardRange.month => dailyBudget * daysInMonth(now).toDouble(),
  };

  final txRepo = ref.watch(transactionsRepositoryProvider);

  return txRepo.watchRange(start: start, end: end).map((txs) {
    final spent = txs.fold<double>(0, (sum, tx) => sum + tx.amount);
    final remaining = rangeBudget - spent;
    final progress =
    rangeBudget <= 0 ? 0.0 : (spent / rangeBudget).clamp(0.0, 1.0);

    return DashboardSummary(
      range: range,
      budget: rangeBudget,
      spent: spent,
      remaining: remaining,
      progress: progress,
      currency: b.currencySymbol,
    );
  });
});