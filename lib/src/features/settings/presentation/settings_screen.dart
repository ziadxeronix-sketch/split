import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme_mode_provider.dart';
import '../../../theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../transactions/presentation/transactions_providers.dart';
import 'appearance_settings_sheet.dart';
import 'notifications_settings_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();

    ref.invalidate(transactionsRepositoryProvider);
    ref.invalidate(latestTransactionsProvider);
    ref.invalidate(budgetRepositoryProvider);
    ref.invalidate(activeBudgetProvider);
    ref.invalidate(categoriesRepositoryProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(dashboardRangeProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: _GlowCircle(
              color: AppTheme.violetPrimary.withOpacity(
                theme.brightness == Brightness.dark ? 0.12 : 0.05,
              ),
              size: 500,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _GlowCircle(
              color: AppTheme.tealSuccess.withOpacity(
                theme.brightness == Brightness.dark ? 0.10 : 0.03,
              ),
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
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.92),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  title: Text(
                    'Settings',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: cs.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(context),
                    const SizedBox(height: 40),
                    _buildSectionHeader(context, 'Preferences'),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context, [
                      _SettingsItem(
                        icon: Icons.category_rounded,
                        title: 'Categories',
                        subtitle: 'Customize your spending tags',
                        onTap: () => context.push('/app/categories'),
                      ),
                      _SettingsItem(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Subscription',
                        subtitle: 'Manage your pro features',
                        onTap: () => context.push('/app/subscription'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.violetPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.violetPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, 'App Configuration'),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context, [
                      _SettingsItem(
                        icon: Icons.palette_rounded,
                        title: 'Appearance',
                        subtitle: switch (currentMode) {
                          ThemeMode.system => 'Following system theme',
                          ThemeMode.light => 'Light mode enabled',
                          ThemeMode.dark => 'Dark mode enabled',
                        },
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor:
                          theme.bottomSheetTheme.backgroundColor,
                          showDragHandle: false,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          builder: (_) => const AppearanceSettingsSheet(),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_active_rounded,
                        title: 'Notifications',
                        subtitle: 'Daily reminders & alerts',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor:
                          theme.bottomSheetTheme.backgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          builder: (_) => const NotificationsSettingsSheet(),
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.security_rounded,
                        title: 'Security',
                        subtitle: 'Data protection & locks',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 40),
                    _buildLogoutButton(context, ref),
                    const SizedBox(height: 32),
                    Text(
                      'SplitBrain v1.0.0',
                      style: GoogleFonts.plusJakartaSans(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.violetPrimary.withOpacity(0.18),
                  AppTheme.violetPrimary.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.violetPrimary,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personal Finance Pro',
                  style: GoogleFonts.plusJakartaSans(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: cs.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.pinkAlert.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: () => _handleSignOut(context, ref),
        icon: const Icon(Icons.logout_rounded, size: 22),
        label: const Text('Sign Out Account'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.pinkAlert,
          backgroundColor: Theme.of(context).cardColor,
          side: BorderSide(
            color: AppTheme.pinkAlert.withOpacity(0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppTheme.violetPrimary, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: cs.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: cs.onSurfaceVariant,
          ),
      onTap: onTap,
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({
    required this.color,
    required this.size,
  });

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