import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthService with ChangeNotifier {
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResultStatus> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    }
  }

  Future<AuthResultStatus> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();

  AuthResultStatus _handleFirebaseAuthException(FirebaseAuthException e) {
    AuthResultStatus status;
    switch (e.code) {
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "user-disabled":
        status = AuthResultStatus.userDisabled;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "too-many-requests":
        status = AuthResultStatus.tooManyRequests;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }
}
