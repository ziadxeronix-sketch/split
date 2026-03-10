import '../../../core/date_utils.dart';
import 'stats_model.dart';

class GamificationEngine {
  static UserStats nextStats({
    required UserStats current,
    required DateTime createdAt,
  }) {
    final todayKey = dayKey(createdAt);
    final last = current.lastEntryDate;

    int streak = current.streakCount;
    if (last == null) {
      streak = 1;
    } else if (last == todayKey) {
      streak = current.streakCount;
    } else {
      final lastDt = parseDayKey(last);
      final diff = createdAt.difference(startOfDay(lastDt)).inDays;
      streak = diff == 1 ? current.streakCount + 1 : 1;
    }

    final total = current.totalEntries + 1;
    final badges = {...current.badges};
    if (total >= 1) badges.add('first_expense');
    if (total >= 10) badges.add('ten_entries');
    if (total >= 50) badges.add('fifty_entries');
    if (streak >= 3) badges.add('streak_3');
    if (streak >= 7) badges.add('streak_7');

    return UserStats(
      streakCount: streak,
      totalEntries: total,
      lastEntryDate: todayKey,
      badges: badges.toList()..sort(),
      updatedAt: DateTime.now(),
    );
  }
}
