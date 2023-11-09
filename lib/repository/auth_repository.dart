import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  // private constructor
  AuthRepository._();

  // create instance of AuthRepository
  static AuthRepository instance = AuthRepository._();

  // create instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;

  // signup method
  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // login method
  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  // reset password method
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  User? get currentUser => _auth.currentUser;
}
