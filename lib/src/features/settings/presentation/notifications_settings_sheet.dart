import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/notifications/notification_coordinator.dart';
import '../../../core/notifications/notification_preferences.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../theme/app_theme.dart';

class NotificationsSettingsSheet extends ConsumerStatefulWidget {
  const NotificationsSettingsSheet({super.key});

  @override
  ConsumerState<NotificationsSettingsSheet> createState() => _NotificationsSettingsSheetState();
}

class _NotificationsSettingsSheetState extends ConsumerState<NotificationsSettingsSheet> {
  NotificationPreferences? _draft;
  bool _saving = false;

  Future<void> _save(NotificationPreferences prefs) async {
    setState(() => _saving = true);
    try {
      await ref.read(notificationCoordinatorProvider).savePreferences(prefs);
      ref.invalidate(notificationPreferencesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification settings updated.', 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          backgroundColor: AppTheme.violetPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _requestPermission() async {
    final granted = await ref.read(notificationCoordinatorProvider).requestPermissionAndSync();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted ? 'Notification permission granted.' : 'Notification permission was not granted.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: granted ? AppTheme.tealSuccess : AppTheme.pinkAlert,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPrefs = ref.watch(notificationPreferencesProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return asyncPrefs.when(
      loading: () => const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: AppTheme.violetPrimary)),
      ),
      error: (e, _) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.pinkAlert, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load settings', 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text('$e', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted)),
          ],
        ),
      ),
      data: (prefs) {
        _draft ??= prefs;
        final value = _draft!;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Notifications & Alerts',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800, 
                                fontSize: 24,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Keep your financial habits sharp with smart reminders.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant, 
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Permission Button - More Elegant
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.notifications_active_rounded, size: 20),
                          label: Text('Allow system notifications', 
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.violetPrimary,
                            side: BorderSide(color: AppTheme.violetPrimary.withOpacity(0.2), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      _SwitchTile(
                        title: 'Enable Notifications',
                        subtitle: 'Master switch for all app alerts.',
                        value: value.enabled,
                        onChanged: (v) => setState(() => _draft = value.copyWith(enabled: v)),
                        isMaster: true,
                      ),
                      const SizedBox(height: 8),
                      
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: value.enabled ? 1.0 : 0.5,
                        child: Column(
                          children: [
                            _SwitchTile(
                              title: 'Budget Thresholds',
                              subtitle: 'Alerts at 80% and 100% of limits.',
                              value: value.enabled && value.budgetAlerts,
                              onChanged: value.enabled ? (v) => setState(() => _draft = value.copyWith(budgetAlerts: v)) : null,
                            ),
                            _SwitchTile(
                              title: 'Overspending Detection',
                              subtitle: 'Alerts for category spikes.',
                              value: value.enabled && value.overspendingAlerts,
                              onChanged: value.enabled ? (v) => setState(() => _draft = value.copyWith(overspendingAlerts: v)) : null,
                            ),
                            _SwitchTile(
                              title: 'Habit Reminders',
                              subtitle: 'Nudge when inactive for too long.',
                              value: value.enabled && value.inactivityAlerts,
                              onChanged: value.enabled ? (v) => setState(() => _draft = value.copyWith(inactivityAlerts: v)) : null,
                            ),
                            _SwitchTile(
                              title: 'Daily Check-in',
                              subtitle: 'Log your daily expenses.',
                              value: value.enabled && value.dailyReminder,
                              onChanged: value.enabled ? (v) => setState(() => _draft = value.copyWith(dailyReminder: v)) : null,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      _SectionLabel(label: 'Custom Schedule'),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Reminder', 
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 8),
                                _CustomDropdown<int>(
                                  value: value.reminderHour,
                                  items: [
                                    for (int hour = 6; hour <= 23; hour++)
                                      DropdownMenuItem(value: hour, child: Text(_formatHour(hour))),
                                  ],
                                  onChanged: value.enabled && value.dailyReminder
                                      ? (hour) => setState(() => _draft = value.copyWith(reminderHour: hour ?? value.reminderHour))
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Inactivity Gap', 
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 8),
                                _CustomDropdown<int>(
                                  value: value.inactivityDays,
                                  items: const [
                                    DropdownMenuItem(value: 1, child: Text('1 day')),
                                    DropdownMenuItem(value: 2, child: Text('2 days')),
                                    DropdownMenuItem(value: 3, child: Text('3 days')),
                                    DropdownMenuItem(value: 5, child: Text('5 days')),
                                    DropdownMenuItem(value: 7, child: Text('7 days')),
                                  ],
                                  onChanged: value.enabled && value.inactivityAlerts
                                      ? (days) => setState(() => _draft = value.copyWith(inactivityDays: days ?? value.inactivityDays))
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : () => _save(value),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.violetPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 8,
                            shadowColor: AppTheme.violetPrimary.withOpacity(0.4),
                          ),
                          child: _saving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Save Changes', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatHour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final shown = hour % 12 == 0 ? 12 : hour % 12;
    return '$shown:00 $suffix';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            color: Theme.of(context).colorScheme.onSurfaceVariant, 
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: AppTheme.textDark.withOpacity(0.05))),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isMaster = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isMaster;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isMaster ? AppTheme.violetPrimary.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.03) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMaster 
              ? AppTheme.violetPrimary.withOpacity(0.1) 
              : Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800, 
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, 
                  style: GoogleFonts.plusJakartaSans(
                    color: Theme.of(context).colorScheme.onSurfaceVariant, 
                    fontSize: 12, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeColor: AppTheme.violetPrimary,
            activeTrackColor: AppTheme.violetPrimary.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}

class _CustomDropdown<T> extends StatelessWidget {
  const _CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
          style: GoogleFonts.plusJakartaSans(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Theme.of(context).cardColor,
          elevation: 8,
        ),
      ),
    );
  }
}
