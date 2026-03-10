import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/presentation/categories_providers.dart';
import 'transactions_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestTransactionsProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final budgetAsync = ref.watch(activeBudgetProvider);
    final df = DateFormat('MMM d, h:mm a');
    final currency = budgetAsync.asData?.value?.currencySymbol ?? '€';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Elegant Background Accents
          Positioned(
            top: -150,
            left: -100,
            child: _GlowCircle(
              color: AppTheme.violetPrimary.withOpacity(0.05),
              size: 500,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _GlowCircle(
              color: AppTheme.pinkAlert.withOpacity(0.03),
              size: 400,
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.blurBackground],
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: Text(
                    'Transactions',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800, 
                      fontSize: 24,
                      color: AppTheme.textDark,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: AppTheme.textDark),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              async.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: Center(child: Text('Something went wrong\n$e')),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const SliverFillRemaining(child: _EmptyState());
                  }
                  final catMap = <String, String>{
                    for (final c in catsAsync.asData?.value ?? const []) c.id: c.name,
                  };
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final tx = items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TransactionListItem(
                              tx: tx,
                              catName: catMap[tx.categoryId] ?? tx.categoryId,
                              currency: currency,
                              dateFormat: df,
                              onDelete: () => ref.read(transactionsRepositoryProvider).delete(tx.id),
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final dynamic tx;
  final String catName;
  final String currency;
  final DateFormat dateFormat;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.tx,
    required this.catName,
    required this.currency,
    required this.dateFormat,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(tx.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.pinkAlert.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.pinkAlert, size: 28),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.violetPrimary.withOpacity(0.08),
                    AppTheme.violetPrimary.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.violetPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note?.isNotEmpty == true ? tx.note! : catName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(tx.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- $currency${tx.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppTheme.pinkAlert,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.greySecondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Cash',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.violetPrimary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 64, color: AppTheme.violetPrimary),
            ),
            const SizedBox(height: 32),
            Text(
              'Your History is Empty',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, 
                fontSize: 22, 
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first expense to see the magic happen here.',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted, 
                fontSize: 15, 
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
