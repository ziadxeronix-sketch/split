import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../domain/gamification_badges.dart';
import '../domain/stats_model.dart';
import 'gamification_providers.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FF),
        surfaceTintColor: const Color(0xFFF7F8FF),
        elevation: 0,
        title: Text(
          'Gamification',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: ref.watch(statsProvider).when(
            data: (stats) => _Body(stats: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                'Could not load your progress.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
            ),
          ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final nextBadge = GamificationCatalog.nextLocked(stats);
    final unlockedCount = GamificationCatalog.unlockedCount(stats);
    final level = GamificationCatalog.levelFor(stats);
    final levelProgress = GamificationCatalog.levelProgress(stats);
    final nextLevelPoints = GamificationCatalog.nextLevelPoints(stats);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _HeroCard(
          stats: stats,
          level: level,
          levelProgress: levelProgress,
          nextLevelPoints: nextLevelPoints,
          unlockedCount: unlockedCount,
        ),
        const SizedBox(height: 20),
        _SectionTitle(
          title: 'Your momentum',
          subtitle: 'A polished view of progress, streaks, and habit wins.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Current streak',
                value: '${stats.streakCount}',
                hint: 'days in a row',
                icon: Icons.local_fire_department_rounded,
                accent: AppTheme.amberWarning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Best streak',
                value: '${stats.longestStreak}',
                hint: 'record days',
                icon: Icons.emoji_events_rounded,
                accent: AppTheme.tealSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Expenses logged',
                value: '${stats.totalEntries}',
                hint: 'total entries',
                icon: Icons.receipt_long_rounded,
                accent: AppTheme.violetPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'XP earned',
                value: '${stats.points}',
                hint: 'habit points',
                icon: Icons.auto_awesome_rounded,
                accent: AppTheme.pinkAlert,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (nextBadge != null) ...[
          _SectionTitle(
            title: 'Next milestone',
            subtitle: 'This keeps the feature feeling alive and goal-driven.',
          ),
          const SizedBox(height: 14),
          _NextBadgeCard(badge: nextBadge, stats: stats),
          const SizedBox(height: 22),
        ],
        _SectionTitle(
          title: 'Badge collection',
          subtitle: '$unlockedCount of ${GamificationCatalog.all.length} unlocked',
        ),
        const SizedBox(height: 14),
        ...GamificationCatalog.all.map(
          (badge) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BadgeTile(
              badge: badge,
              stats: stats,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.stats,
    required this.level,
    required this.levelProgress,
    required this.nextLevelPoints,
    required this.unlockedCount,
  });

  final UserStats stats;
  final int level;
  final double levelProgress;
  final int nextLevelPoints;
  final int unlockedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.violetPrimary, Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.violetPrimary.withOpacity(0.26),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'LEVEL $level',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.workspace_premium_rounded, color: Colors.white.withOpacity(0.9)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Build stronger money habits every day.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have $unlockedCount badges, ${stats.points} XP, and a ${stats.streakCount}-day streak.',
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.82),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: levelProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${stats.points} / $nextLevelPoints XP to next level',
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String hint;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.08)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.nunito(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(hint, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _NextBadgeCard extends StatelessWidget {
  const _NextBadgeCard({required this.badge, required this.stats});

  final GamificationBadgeDefinition badge;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final progress = badge.progress(stats);
    final remaining = badge.remaining(stats);
    final accent = _badgeAccent(badge.iconKey);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgeIcon(iconKey: badge.iconKey, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.title,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remaining ${badge.progressLabel} left',
                      style: GoogleFonts.nunito(color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            badge.description,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: accent.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.stats});

  final GamificationBadgeDefinition badge;
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked(stats);
    final accent = _badgeAccent(badge.iconKey);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: unlocked ? 1 : 0.72,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: unlocked ? accent.withOpacity(0.2) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            _BadgeIcon(iconKey: badge.iconKey, accent: accent, locked: !unlocked),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          badge.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (unlocked ? accent : AppTheme.textMuted).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          unlocked ? 'Unlocked' : 'In progress',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: unlocked ? accent : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.description,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: badge.progress(stats),
                      minHeight: 8,
                      backgroundColor: Colors.black.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unlocked
                        ? 'Completed'
                        : '${badge.progressValue(stats)} / ${badge.target} ${badge.progressLabel}',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.iconKey, required this.accent, this.locked = false});

  final String iconKey;
  final Color accent;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: (locked ? AppTheme.textMuted : accent).withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(_iconFor(iconKey), color: locked ? AppTheme.textMuted : accent),
    );
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'spark':
      return Icons.bolt_rounded;
    case 'compass':
      return Icons.explore_rounded;
    case 'flame':
      return Icons.local_fire_department_rounded;
    case 'shield':
      return Icons.verified_user_rounded;
    case 'trophy':
      return Icons.emoji_events_rounded;
    case 'crown':
      return Icons.workspace_premium_rounded;
    default:
      return Icons.stars_rounded;
  }
}

Color _badgeAccent(String key) {
  switch (key) {
    case 'spark':
      return AppTheme.pinkAlert;
    case 'compass':
      return AppTheme.violetPrimary;
    case 'flame':
      return AppTheme.amberWarning;
    case 'shield':
      return AppTheme.tealSuccess;
    case 'trophy':
      return const Color(0xFF2563EB);
    case 'crown':
      return const Color(0xFF9333EA);
    default:
      return AppTheme.violetPrimary;
  }
}
