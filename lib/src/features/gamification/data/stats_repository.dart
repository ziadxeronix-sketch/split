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

      // أكثر احترافية: نقاط مبنية على الحجم + الاستمرارية + فتح البادجات
      // - 10 نقاط لكل إدخال جديد
      // - 2 نقطة عن كل يوم في الـ streak الحالي
      // - 25 نقطة لكل بادج جديدة
      final basePoints = 10;
      final streakBonus = streak * 2;
      final badgeBonus = newUnlockCount * 25;
      final points = current.points + basePoints + streakBonus + badgeBonus;

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
    // Core badges (حديثة)
    if (total >= 1) badges.add('starter_spark'); // أول مصروف
    if (total >= 10) badges.add('expense_explorer'); // 10 إدخالات
    if (total >= 25) badges.add('habit_builder'); // 25 إدخال
    if (total >= 50) badges.add('money_master'); // 50 إدخال
    if (total >= 100) badges.add('centurion'); // 100 إدخال

    if (streak >= 3) badges.add('consistency_starter'); // 3 أيام متتالية
    if (streak >= 7) badges.add('streak_champion'); // أسبوع كامل
    if (streak >= 14) badges.add('habit_keeper'); // أسبوعين متتاليين
    if (streak >= 30) badges.add('discipline_legend'); // شهر متواصل

    // legacy compatibility so older UI/state still makes sense إذا استُخدمت في مكان آخر
    if (total >= 1) badges.add('first_expense');
    if (total >= 10) badges.add('ten_entries');
    if (total >= 50) badges.add('fifty_entries');
    if (streak >= 3) badges.add('streak_3');
    if (streak >= 7) badges.add('streak_7');
  }
}
