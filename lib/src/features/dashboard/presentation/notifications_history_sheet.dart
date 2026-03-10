import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:splitbrain/src/core/notifications/notification_model.dart';
import 'package:splitbrain/src/core/notifications/notification_providers.dart';
import 'package:splitbrain/src/theme/app_theme.dart';
import 'package:splitbrain/src/features/settings/presentation/notifications_settings_sheet.dart';

class NotificationsHistorySheet extends ConsumerWidget {
  const NotificationsHistorySheet({super.key});

  void _openSettings(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(notificationHistoryProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: AppTheme.textDark,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        'Recent alerts and updates',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderActionButton(
                  icon: Icons.settings_outlined,
                  onTap: () => _openSettings(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Flexible(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return SingleChildScrollView(
                    child: _buildEmptyState(),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return _NotificationCard(
                            notification: history[index],
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 16),
                        child: TextButton(
                          onPressed: () async {
                            await ref
                                .read(notificationHistoryServiceProvider)
                                .clearAll();
                            ref.invalidate(notificationHistoryProvider);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.pinkAlert,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                          ),
                          child: Text(
                            'Clear All Notifications',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.violetPrimary,
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.violetPrimary.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: AppTheme.violetPrimary.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'No notifications yet',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'When you receive alerts about your budget or habits, they will show up here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(notification.category);
    final icon = _getCategoryIcon(notification.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryName(notification.category).toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notification.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    return DateFormat('MMM d, h:mm a').format(dt);
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'budget_exceeded':
        return AppTheme.pinkAlert;
      case 'budget_near':
        return AppTheme.amberWarning;
      case 'overspending':
        return const Color(0xFF6366F1);
      case 'habit':
        return AppTheme.tealSuccess;
      default:
        return AppTheme.violetPrimary;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'budget_exceeded':
        return Icons.report_problem_rounded;
      case 'budget_near':
        return Icons.notifications_active_rounded;
      case 'overspending':
        return Icons.trending_up_rounded;
      case 'habit':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getCategoryName(String cat) {
    switch (cat) {
      case 'budget_exceeded':
        return 'Limit Hit';
      case 'budget_near':
        return 'Warning';
      case 'overspending':
        return 'Insight';
      case 'habit':
        return 'Habit';
      default:
        return 'Alert';
    }
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textDark.withValues(alpha: 0.05),
            ),
          ),
          child: Icon(
            icon,
            color: color ?? AppTheme.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}