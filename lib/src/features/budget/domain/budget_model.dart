import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetPeriod { weekly, monthly }

class Budget {
  const Budget({
    required this.period,
    required this.amount,
    required this.currencySymbol,
  });

  final BudgetPeriod period;
  final double amount;
  final String currencySymbol;

  Map<String, dynamic> toJson() => {
        'period': period.name,
        'amount': amount,
        'currencySymbol': currencySymbol,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Budget fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final p = (data['period'] as String?) ?? 'monthly';
    return Budget(
      period: p == 'weekly' ? BudgetPeriod.weekly : BudgetPeriod.monthly,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currencySymbol: (data['currencySymbol'] as String?) ?? '€',
    );
  }
}
