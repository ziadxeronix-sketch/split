import 'package:flutter_test/flutter_test.dart';
import 'package:splitbrain/src/features/gamification/domain/gamification_engine.dart';
import 'package:splitbrain/src/features/gamification/domain/stats_model.dart';

void main() {
  group('GamificationEngine.nextStats', () {
    test('creates first streak and badge on first expense', () {
      final result = GamificationEngine.nextStats(
        current: UserStats.empty,
        createdAt: DateTime(2026, 3, 6, 10),
      );

      expect(result.streakCount, 1);
      expect(result.totalEntries, 1);
      expect(result.badges, contains('first_expense'));
      expect(result.lastEntryDate, '2026-03-06');
    });

    test('keeps same streak when adding twice on same day', () {
      const current = UserStats(
        streakCount: 2,
        totalEntries: 4,
        lastEntryDate: '2026-03-06',
        badges: ['first_expense'],
        updatedAt: null,
      );

      final result = GamificationEngine.nextStats(
        current: current,
        createdAt: DateTime(2026, 3, 6, 20),
      );

      expect(result.streakCount, 2);
      expect(result.totalEntries, 5);
    });

    test('increments streak on consecutive day and unlocks streak badge', () {
      const current = UserStats(
        streakCount: 2,
        totalEntries: 9,
        lastEntryDate: '2026-03-05',
        badges: ['first_expense'],
        updatedAt: null,
      );

      final result = GamificationEngine.nextStats(
        current: current,
        createdAt: DateTime(2026, 3, 6, 8),
      );

      expect(result.streakCount, 3);
      expect(result.totalEntries, 10);
      expect(result.badges, containsAll(['ten_entries', 'streak_3']));
    });

    test('resets streak after gap', () {
      const current = UserStats(
        streakCount: 5,
        totalEntries: 12,
        lastEntryDate: '2026-03-03',
        badges: ['first_expense', 'streak_3'],
        updatedAt: null,
      );

      final result = GamificationEngine.nextStats(
        current: current,
        createdAt: DateTime(2026, 3, 6, 8),
      );

      expect(result.streakCount, 1);
      expect(result.totalEntries, 13);
    });
  });
}
