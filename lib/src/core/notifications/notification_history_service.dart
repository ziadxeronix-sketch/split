import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationHistoryService {
  static const _key = 'notification_history';

  Future<List<AppNotification>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => AppNotification.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();
    current.insert(0, notification);
    
    // Keep only last 50 notifications
    if (current.length > 50) current.removeLast();
    
    await prefs.setStringList(
      _key,
      current.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();
    final updated = current.map((e) {
      if (e.id == id) return e.copyWith(isRead: true);
      return e;
    }).toList();
    
    await prefs.setStringList(
      _key,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
