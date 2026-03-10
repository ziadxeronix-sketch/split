import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
  });

  final String id;
  final String name;
  /// Stored as a string key (e.g. "food", "shopping")
  final String icon;
  final int order;

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'order': order,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static ExpenseCategory fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ExpenseCategory(
      id: doc.id,
      name: (data['name'] as String?) ?? doc.id,
      icon: (data['icon'] as String?) ?? 'other',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
