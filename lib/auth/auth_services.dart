import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class Result<T> {
  final T? data;
  final String? error;

  Result({this.data, this.error});

  bool get isSuccess => data != null;
  bool get isError => error != null;
}

class AuthServices {
  final _auth = FirebaseAuth.instance;

  Future<Result<User?>> signUpWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result(data: credentials.user);
    } on FirebaseAuthException catch (e) {
      late final String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email';
          break;

        case 'operation-not-allowed':
          message = 'Sorry, this account is not authorised to access this app.';
          break;

        case 'weak-password':
          message = 'Please create a strong password';
          break;

        default:
          message = 'Unknown error. Please try again later!';
          break;
      }

      return Result(error: message);
    }
  }

  Future<Result<User?>> signInWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Result(data: credentials.user);
    } on FirebaseAuthException catch (e) {
      late final String message;
      switch (e.code) {
        case 'invalid-credential':
          message = "The credentials doesn't match out records";
          break;

        case 'invalid-email':
          message = 'Please enter a valid email';
          break;

        case 'user-disabled':
          message = 'Sorry, this account is not authorised to access this app.';
          break;

        default:
          message = 'Unknown error. Please try again later!';
      }

      return Result(error: message);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Failed to sign out');
    }
  }
}
