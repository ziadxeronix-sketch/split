import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/date_utils.dart';
import '../../../theme/app_theme.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../transactions/presentation/transactions_providers.dart';
import '../domain/category_model.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  const CategoryDetailsScreen({super.key, required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(dashboardRangeProvider);
    final budgetAsync = ref.watch(activeBudgetProvider);
    final txRepo = ref.watch(transactionsRepositoryProvider);

    final now = DateTime.now();
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

    final currency = budgetAsync.asData?.value?.currencySymbol ?? '€';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.name,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: txRepo.watchRange(start: start, end: end),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final txs = snapshot.data ?? const [];
          final filtered =
              txs.where((tx) => tx.categoryId == category.id).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.greySecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        size: 56,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No spending yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t logged any expenses for this category in the selected period.',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final total = filtered.fold<double>(
            0,
            (sum, tx) => sum + tx.amount,
          );

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.violetPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.violetPrimary.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total spent',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currency${total.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tx.note?.isNotEmpty == true
                                  ? tx.note!
                                  : category.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '- $currency${tx.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.pinkAlert,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filtered.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

