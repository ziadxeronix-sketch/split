import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Future<UserCredential> signInWithEmail({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({required String email, required String password, String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  Future<void> signOut() => _auth.signOut();
}
