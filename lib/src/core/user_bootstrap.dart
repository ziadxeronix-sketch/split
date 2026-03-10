import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserBootstrap {
  UserBootstrap(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<void> ensureUserDoc() async {
    final u = _auth.currentUser;
    if (u == null) return;

    final ref = _db.collection('users').doc(u.uid);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.set({
        'email': u.email,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'email': u.email,
      'displayName': u.displayName,
      'photoUrl': u.photoURL,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'currencySymbol': '€',
      'weekStartDay': 1,
    }, SetOptions(merge: true));
  }
}
