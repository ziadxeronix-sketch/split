import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme_mode_provider.dart';
import '../../../theme/app_theme.dart';

class AppearanceSettingsSheet extends ConsumerWidget {
  const AppearanceSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Appearance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how SplitBrain looks across the entire app.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _AppearanceOption(
            icon: Icons.phone_android_rounded,
            title: 'System',
            subtitle: 'Follow your device setting',
            selected: current == ThemeMode.system,
            onTap: () async {
              await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _AppearanceOption(
            icon: Icons.light_mode_rounded,
            title: 'Light',
            subtitle: 'Always use the light theme',
            selected: current == ThemeMode.light,
            onTap: () async {
              await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _AppearanceOption(
            icon: Icons.dark_mode_rounded,
            title: 'Dark',
            subtitle: 'Always use the dark theme',
            selected: current == ThemeMode.dark,
            onTap: () async {
              await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected ? AppTheme.violetPrimary.withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.08) : theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppTheme.violetPrimary : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.violetPrimary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: selected ? Colors.white : cs.onSurfaceVariant),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? AppTheme.violetPrimary : cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
