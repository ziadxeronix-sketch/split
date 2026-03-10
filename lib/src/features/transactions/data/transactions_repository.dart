import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../domain/transaction_model.dart';

class TransactionsRepository {
  TransactionsRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('transactions');

  Stream<List<ExpenseTransaction>> watchLatest({int limit = 50}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ExpenseTransaction.fromDoc).toList());
  }

  Stream<List<ExpenseTransaction>> watchRange({required DateTime start, required DateTime end}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ExpenseTransaction.fromDoc).toList());
  }


  Future<List<ExpenseTransaction>> listRangeOnce({required DateTime start, required DateTime end}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    final snap = await _col(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(ExpenseTransaction.fromDoc).toList();
  }

  Future<DateTime?> latestExpenseAt() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    final snap = await _col(uid).orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return ExpenseTransaction.fromDoc(snap.docs.first).createdAt;
  }

  Future<double> sumRangeOnce({required DateTime start, required DateTime end}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    final snap = await _col(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    double sum = 0;
    for (final d in snap.docs) {
      final data = d.data();
      sum += (data['amount'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  Future<void> add({required double amount, required String categoryId, String? note, String source = 'manual'}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    final id = _uuid.v4();

    await _col(uid).doc(id).set({
      'amount': amount,
      'catId': categoryId,
      'note': note,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _col(uid).doc(id).delete();
  }
}
