import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../../../theme/app_theme.dart';
import '../../../core/notifications/notification_coordinator.dart';
import '../../gamification/presentation/gamification_providers.dart';

import '../../budget/presentation/budget_providers.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../transactions/presentation/add_expense_sheet.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../../budget/presentation/budget_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeBootstrap();
    });
  }

  Future<void> _safeBootstrap() async {
    try {
      await ref.read(userBootstrapProvider).ensureUserDoc();
    } catch (e, s) {
      debugPrint('User bootstrap failed: $e');
      debugPrintStack(stackTrace: s);
    }

    try {
      await ref.read(categoriesRepositoryProvider).seedDefaultsIfEmpty();
      await ref.read(statsRepositoryProvider).ensureExists();
      await ref.read(budgetRepositoryProvider).ensureDefault();
    } catch (e, s) {
      debugPrint('Data bootstrap failed: $e');
      debugPrintStack(stackTrace: s);
    }

    // Keep notification setup lazy so startup can never crash.
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      try {
        await ref.read(notificationCoordinatorProvider).bootstrap();
        await ref.read(notificationCoordinatorProvider).checkInactivity();
      } catch (e, s) {
        debugPrint('Notification bootstrap failed: $e');
        debugPrintStack(stackTrace: s);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        ref.read(notificationCoordinatorProvider).checkInactivity();
      } catch (e, s) {
        debugPrint('Lifecycle inactivity check failed: $e');
        debugPrintStack(stackTrace: s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 0: Dashboard, 1: History, 2: Budget, 3: Settings
    final screens = [
      const DashboardScreen(),
      const TransactionsScreen(),
      const BudgetScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.whiteMain,
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppTheme.brandShadow,
        ),
        child: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: AppTheme.whiteMain,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            builder: (_) => const AddExpenseSheet(),
          ),
          backgroundColor: AppTheme.violetPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
      bottomNavigationBar: Container(
        height: 88,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: AppTheme.whiteMain,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppTheme.textDark.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppTheme.violetPrimary.withOpacity(0.1),
            selectedIndex: _index > 1 ? _index + 1 : _index,
            onDestinationSelected: (i) {
              if (i == 2) return; // FAB Gap
              setState(() {
                if (i < 2) {
                  _index = i;
                } else {
                  _index = i - 1;
                }
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              _buildNav(Icons.grid_view_rounded, 'Home'),
              _buildNav(Icons.receipt_long_rounded, 'History'),
              const NavigationDestination(icon: SizedBox.shrink(), label: '', enabled: false),
              _buildNav(Icons.account_balance_wallet_rounded, 'Budget'),
              _buildNav(Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNav(IconData icon, String label) {
    return NavigationDestination(
      icon: Icon(icon, size: 24, color: AppTheme.textMuted),
      selectedIcon: Icon(icon, size: 24, color: AppTheme.violetPrimary),
      label: label,
    );
  }
}
