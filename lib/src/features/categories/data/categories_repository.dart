import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/category_model.dart';

class CategoriesRepository {
  CategoriesRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('categories');

  Stream<List<ExpenseCategory>> watchAll() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col(uid)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(ExpenseCategory.fromDoc).toList());
  }

  Future<List<ExpenseCategory>> getAllOnce() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _col(uid).orderBy('order').get();
    return snap.docs.map(ExpenseCategory.fromDoc).toList();
  }

  Future<void> upsert(ExpenseCategory c) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _col(uid).doc(c.id).set(c.toJson(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _col(uid).doc(id).delete();
  }

  /// Seeds default categories once per user.
  Future<void> seedDefaultsIfEmpty() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final existing = await _col(uid).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final defaults = <ExpenseCategory>[
      const ExpenseCategory(id: 'food', name: 'Food', icon: 'food', order: 0),
      const ExpenseCategory(id: 'coffee', name: 'Coffee', icon: 'coffee', order: 1),
      const ExpenseCategory(id: 'groceries', name: 'Groceries', icon: 'groceries', order: 2),
      const ExpenseCategory(id: 'transport', name: 'Transport', icon: 'transport', order: 3),
      const ExpenseCategory(id: 'shopping', name: 'Shopping', icon: 'shopping', order: 4),
      const ExpenseCategory(id: 'bills', name: 'Bills', icon: 'bills', order: 5),
      const ExpenseCategory(id: 'entertainment', name: 'Fun', icon: 'fun', order: 6),
      const ExpenseCategory(id: 'health', name: 'Health', icon: 'health', order: 7),
      const ExpenseCategory(id: 'other', name: 'Other', icon: 'other', order: 99),
    ];

    final batch = _db.batch();
    for (final c in defaults) {
      batch.set(_col(uid).doc(c.id), c.toJson(), SetOptions(merge: true));
    }
    await batch.commit();
  }
}
