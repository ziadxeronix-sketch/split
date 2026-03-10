import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/date_utils.dart';
import '../../../theme/app_theme.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../gamification/domain/gamification_badges.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../gamification/presentation/gamification_screen.dart';
import 'notifications_history_sheet.dart';
import '../presentation/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showNotifications(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: const NotificationsHistorySheet(),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(dashboardRangeProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final budgetAsync = ref.watch(activeBudgetProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _GlowCircle(
              color: AppTheme.violetPrimary.withOpacity(isDark ? 0.10 : 0.06),
              size: 450,
            ),
          ),
          Positioned(
            top: 250,
            left: -120,
            child: _GlowCircle(
              color: AppTheme.tealSuccess.withOpacity(isDark ? 0.08 : 0.04),
              size: 400,
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 1,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  title: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  centerTitle: false,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _CircleActionButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => _showNotifications(context),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildRangeSelector(context, ref, range),
                      const SizedBox(height: 32),

                      if (budgetAsync.asData?.value == null)
                        _buildSetupBudgetCard(context),

                      summaryAsync.when(
                        data: (s) => _buildMainPremiumCard(s),
                        loading: () => _buildLoadingCard(context),
                        error: (e, _) => Text('Error: $e'),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionHeader(context, 'Smart Insights'),
                      const SizedBox(height: 20),
                      _buildStreakProgressCard(context, ref),

                      const SizedBox(height: 40),
                      _buildSectionHeader(context, 'Categories'),
                      const SizedBox(height: 20),
                      _buildCategoriesGrid(context, ref),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector(
      BuildContext context,
      WidgetRef ref,
      DashboardRange current,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 54,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _RangeTab(
            label: 'Day',
            isSelected: current == DashboardRange.today,
            onTap: () => ref.read(dashboardRangeProvider.notifier).state =
                DashboardRange.today,
          ),
          _RangeTab(
            label: 'Week',
            isSelected: current == DashboardRange.week,
            onTap: () => ref.read(dashboardRangeProvider.notifier).state =
                DashboardRange.week,
          ),
          _RangeTab(
            label: 'Month',
            isSelected: current == DashboardRange.month,
            onTap: () => ref.read(dashboardRangeProvider.notifier).state =
                DashboardRange.month,
          ),
        ],
      ),
    );
  }

  Widget _buildMainPremiumCard(dynamic s) {
    final remaining = s.remaining;
    final isOver = remaining < 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppTheme.violetPrimary.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.violetPrimary,
                    Color(0xFF5B21B6),
                    Color(0xFF4C1D95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'AVAILABLE BALANCE',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Icon(
                        isOver
                            ? Icons.warning_amber_rounded
                            : Icons.auto_graph_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FittedBox(
                    child: Text(
                      money(remaining, symbol: s.currency),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildProgressBar(s.progress),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatDetail(
                        label: 'Spent',
                        value: money(s.spent, symbol: s.currency),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      _StatDetail(
                        label: 'Budget',
                        value: money(s.budget, symbol: s.currency),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFE0E7FF)],
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakProgressCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ref.watch(statsProvider).when(
      data: (stats) {
        final nextBadge = GamificationCatalog.nextLocked(stats);
        final level = GamificationCatalog.levelFor(stats);
        final progress = GamificationCatalog.levelProgress(stats);
        final unlocked = GamificationCatalog.unlockedCount(stats);

        return InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GamificationScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withOpacity(isDark ? 0.16 : 0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
              border: Border.all(
                color: Colors.black.withOpacity(isDark ? 0.10 : 0.03),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFEA580C),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level $level • ${stats.streakCount} Day Streak',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                              color: theme.textTheme.titleLarge?.color ??
                                  AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nextBadge == null
                                ? 'All premium badges unlocked!'
                                : 'Next badge: ${nextBadge.title}',
                            style: GoogleFonts.plusJakartaSans(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7) ??
                                  AppTheme.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniInsight(
                      label: 'Badges',
                      value: '$unlocked / ${GamificationCatalog.all.length}',
                    ),
                    _MiniInsight(label: 'XP', value: '${stats.points}'),
                    _MiniInsight(
                      label: 'Entries',
                      value: '${stats.totalEntries}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, WidgetRef ref) {
    return ref.watch(categoriesProvider).when(
      data: (cats) {
        final quick = cats.take(8).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemCount: quick.length,
          itemBuilder: (context, index) {
            final c = quick[index];
            return _CategoryCard(iconKey: c.icon, label: c.name);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color ?? AppTheme.textDark,
            letterSpacing: -0.8,
          ),
        ),
        Text(
          'See all',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.violetPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSetupBudgetCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.violetPrimary.withOpacity(isDark ? 0.12 : 0.04),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.violetPrimary.withOpacity(isDark ? 0.20 : 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violetPrimary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.wallet_rounded,
              color: AppTheme.violetPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Splitbrain',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set a budget to start tracking your expenses and reach your financial goals.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  AppTheme.textMuted,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: (theme.textTheme.bodyMedium?.color ?? AppTheme.textDark)
              .withOpacity(0.05),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 3),
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

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: theme.iconTheme.color ?? AppTheme.textDark,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniInsight extends StatelessWidget {
  const _MiniInsight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                AppTheme.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: theme.textTheme.titleLarge?.color ?? AppTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.violetPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppTheme.violetPrimary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  AppTheme.textMuted),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatDetail extends StatelessWidget {
  final String label;
  final String value;

  const _StatDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double opacity;

  const _IconBox({
    required this.icon,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.iconKey, required this.label});

  final String iconKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    switch (iconKey) {
      case 'coffee':
        icon = Icons.coffee_rounded;
        break;
      case 'food':
        icon = Icons.restaurant_rounded;
        break;
      case 'groceries':
        icon = Icons.shopping_basket_rounded;
        break;
      case 'transport':
        icon = Icons.directions_bus_rounded;
        break;
      case 'shopping':
        icon = Icons.local_mall_rounded;
        break;
      case 'bills':
        icon = Icons.receipt_rounded;
        break;
      case 'fun':
        icon = Icons.confirmation_number_rounded;
        break;
      case 'health':
        icon = Icons.medical_services_rounded;
        break;
      default:
        icon = Icons.category_rounded;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.16 : 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.violetPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color ?? AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}