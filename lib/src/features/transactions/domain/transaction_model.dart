import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
    this.note,
    this.source = 'manual',
  });

  final String id;
  final double amount;
  final String categoryId;
  final DateTime createdAt;
  final String? note;
  final String source;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'catId': categoryId,
        'note': note,
        'source': source,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static ExpenseTransaction fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return ExpenseTransaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryId: (data['categoryId'] as String?) ?? (data['catId'] as String?) ?? 'other',
      note: data['note'] as String?,
      source: (data['source'] as String?) ?? 'manual',
      createdAt: (ts is Timestamp) ? ts.toDate() : DateTime.now(),
    );
  }
}
