import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  const UserStats({
    required this.streakCount,
    required this.longestStreak,
    required this.totalEntries,
    required this.points,
    required this.lastEntryDate, // yyyy-MM-dd (local)
    required this.badges,
    required this.updatedAt,
  });

  final int streakCount;
  final int longestStreak;
  final int totalEntries;
  final int points;
  final String? lastEntryDate;
  final List<String> badges;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'streakCount': streakCount,
        'longestStreak': longestStreak,
        'totalEntries': totalEntries,
        'points': points,
        'lastEntryDate': lastEntryDate,
        'badges': badges,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static UserStats fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['updatedAt'];
    return UserStats(
      streakCount: (data['streakCount'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longestStreak'] as num?)?.toInt() ?? 0,
      totalEntries: (data['totalEntries'] as num?)?.toInt() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 0,
      lastEntryDate: data['lastEntryDate'] as String?,
      badges: (data['badges'] as List?)?.whereType<String>().toList() ?? const [],
      updatedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  static const empty = UserStats(
    streakCount: 0,
    longestStreak: 0,
    totalEntries: 0,
    points: 0,
    lastEntryDate: null,
    badges: [],
    updatedAt: null,
  );
}
