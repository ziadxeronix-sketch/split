import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_bootstrap.dart';

final firebaseReadyProvider = Provider<bool>((ref) => Firebase.apps.isNotEmpty);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userBootstrapProvider = Provider<UserBootstrap>((ref) {
  return UserBootstrap(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});
