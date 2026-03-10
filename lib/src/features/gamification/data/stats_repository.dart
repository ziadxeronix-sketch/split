import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/date_utils.dart';
import '../domain/stats_model.dart';

class StatsRepository {
  StatsRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('meta').doc('stats');

  Stream<UserStats> watch() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _doc(uid).snapshots().map((d) => d.exists ? UserStats.fromDoc(d) : UserStats.empty);
  }

  Future<void> ensureExists() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final d = await _doc(uid).get();
    if (d.exists) return;
    await _doc(uid).set(UserStats.empty.toJson());
  }

  Future<UserStats> onExpenseAdded({required DateTime createdAt}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    final todayKey = dayKey(createdAt);
    final ref = _doc(uid);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? UserStats.fromDoc(snap) : UserStats.empty;

      final last = current.lastEntryDate;
      int streak = current.streakCount;
      if (last == null) {
        streak = 1;
      } else if (last == todayKey) {
        // Same day -> keep streak
      } else {
        final lastDt = parseDayKey(last);
        final diff = createdAt.difference(startOfDay(lastDt)).inDays;
        if (diff == 1) {
          streak = streak + 1;
        } else {
          streak = 1;
        }
      }

      final total = current.totalEntries + 1;
      final longestStreak = streak > current.longestStreak ? streak : current.longestStreak;
      final badges = {...current.badges};

      _unlockBadges(total: total, streak: streak, badges: badges);

      final newUnlockCount = badges.length - current.badges.toSet().length;
      final points = current.points + 15 + (streak > current.streakCount ? 5 : 0) + (newUnlockCount * 20);

      final updated = UserStats(
        streakCount: streak,
        longestStreak: longestStreak,
        totalEntries: total,
        points: points,
        lastEntryDate: todayKey,
        badges: badges.toList()..sort(),
        updatedAt: DateTime.now(),
      );

      tx.set(ref, updated.toJson(), SetOptions(merge: true));
      return updated;
    });
  }

  void _unlockBadges({
    required int total,
    required int streak,
    required Set<String> badges,
  }) {
    if (total >= 1) badges.add('starter_spark');
    if (total >= 5) badges.add('expense_explorer');
    if (streak >= 3) badges.add('consistency_starter');
    if (total >= 15) badges.add('budget_builder');
    if (streak >= 7) badges.add('streak_champion');
    if (total >= 30) badges.add('money_master');

    // legacy compatibility so older UI/state still makes sense if referenced anywhere
    if (total >= 1) badges.add('first_expense');
    if (total >= 10) badges.add('ten_entries');
    if (total >= 50) badges.add('fifty_entries');
    if (streak >= 3) badges.add('streak_3');
    if (streak >= 7) badges.add('streak_7');
  }
}
