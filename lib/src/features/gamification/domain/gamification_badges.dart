import 'stats_model.dart';

class GamificationBadgeDefinition {
  const GamificationBadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.progressLabel,
    required this.iconKey,
    required this.target,
    required this.progressValue,
  });

  final String id;
  final String title;
  final String description;
  final String progressLabel;
  final String iconKey;
  final int target;
  final int Function(UserStats stats) progressValue;

  bool isUnlocked(UserStats stats) => progressValue(stats) >= target || stats.badges.contains(id);

  double progress(UserStats stats) {
    if (target <= 0) return 1;
    return (progressValue(stats) / target).clamp(0, 1).toDouble();
  }

  int remaining(UserStats stats) {
    final remaining = target - progressValue(stats);
    return remaining < 0 ? 0 : remaining;
  }
}

class GamificationCatalog {
  static const all = <GamificationBadgeDefinition>[
    GamificationBadgeDefinition(
      id: 'starter_spark',
      title: 'Starter Spark',
      description: 'Log your very first expense and ignite your tracking habit.',
      progressLabel: 'expenses logged',
      iconKey: 'spark',
      target: 1,
      progressValue: _entries,
    ),
    GamificationBadgeDefinition(
      id: 'expense_explorer',
      title: 'Expense Explorer',
      description: 'Capture 5 expenses to build your money story.',
      progressLabel: 'expenses logged',
      iconKey: 'compass',
      target: 5,
      progressValue: _entries,
    ),
    GamificationBadgeDefinition(
      id: 'consistency_starter',
      title: 'Consistency Starter',
      description: 'Keep a 3-day logging streak alive.',
      progressLabel: 'streak days',
      iconKey: 'flame',
      target: 3,
      progressValue: _streak,
    ),
    GamificationBadgeDefinition(
      id: 'budget_builder',
      title: 'Budget Builder',
      description: 'Reach 15 total entries and make budgeting a routine.',
      progressLabel: 'expenses logged',
      iconKey: 'shield',
      target: 15,
      progressValue: _entries,
    ),
    GamificationBadgeDefinition(
      id: 'streak_champion',
      title: 'Streak Champion',
      description: 'Maintain a 7-day streak like a pro.',
      progressLabel: 'streak days',
      iconKey: 'trophy',
      target: 7,
      progressValue: _streak,
    ),
    GamificationBadgeDefinition(
      id: 'money_master',
      title: 'Money Master',
      description: 'Log 30 expenses and unlock your premium habit milestone.',
      progressLabel: 'expenses logged',
      iconKey: 'crown',
      target: 30,
      progressValue: _entries,
    ),
  ];

  static GamificationBadgeDefinition? nextLocked(UserStats stats) {
    for (final badge in all) {
      if (!badge.isUnlocked(stats)) return badge;
    }
    return null;
  }

  static int unlockedCount(UserStats stats) => all.where((badge) => badge.isUnlocked(stats)).length;

  static int levelFor(UserStats stats) => (stats.points ~/ 120) + 1;

  static int currentLevelBasePoints(UserStats stats) {
    final level = levelFor(stats);
    return (level - 1) * 120;
  }

  static int nextLevelPoints(UserStats stats) {
    final level = levelFor(stats);
    return level * 120;
  }

  static double levelProgress(UserStats stats) {
    final currentBase = currentLevelBasePoints(stats);
    final nextBase = nextLevelPoints(stats);
    final span = (nextBase - currentBase).clamp(1, 1 << 30);
    return ((stats.points - currentBase) / span).clamp(0, 1).toDouble();
  }

  static int _entries(UserStats stats) => stats.totalEntries;
  static int _streak(UserStats stats) => stats.streakCount;
}
