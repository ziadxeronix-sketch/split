import 'package:intl/intl.dart';

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

/// Monday = 1 ... Sunday = 7
DateTime startOfWeek(DateTime d, {int weekStart = DateTime.monday}) {
  final normalized = startOfDay(d);
  final diff = (normalized.weekday - weekStart) % 7;
  return normalized.subtract(Duration(days: diff));
}

DateTime endOfWeek(DateTime d, {int weekStart = DateTime.monday}) {
  final s = startOfWeek(d, weekStart: weekStart);
  return endOfDay(s.add(const Duration(days: 6)));
}

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime endOfMonth(DateTime d) => endOfDay(DateTime(d.year, d.month + 1, 0));

int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

String money(double value, {String symbol = '€'}) {
  final f = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
  return f.format(value);
}

String dayKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

DateTime parseDayKey(String key) => DateFormat('yyyy-MM-dd').parse(key);
