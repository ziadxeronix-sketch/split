import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/budget_model.dart';

class BudgetRepository {
  BudgetRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('budgets').doc('active');

  Stream<Budget?> watchActive() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _doc(uid).snapshots().map((d) => d.exists ? Budget.fromDoc(d) : null);
  }

  Future<Budget?> getActiveOnce() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final d = await _doc(uid).get();
    return d.exists ? Budget.fromDoc(d) : null;
  }

  Future<void> setActive(Budget budget) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');
    await _doc(uid).set(budget.toJson(), SetOptions(merge: true));
  }

  /// Creates a sane default budget if none exists.
  Future<void> ensureDefault() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final d = await _doc(uid).get();
    if (d.exists) return;
    await _doc(uid).set(const Budget(period: BudgetPeriod.monthly, amount: 600, currencySymbol: '€').toJson());
  }
}
