import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showErrorToast(e.message ?? 'An error occurred during sign up.');
      return null;
    } catch (e) {
      _showErrorToast('An unexpected error occurred.');
      return null;
    }
  }

  // Login
  Future<UserCredential?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showErrorToast(e.message ?? 'An error occurred during login.');
      return null;
    } catch (e) {
      _showErrorToast('An unexpected error occurred.');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _showErrorToast('Error signing out.');
    }
  }

  // Helper to show toast
  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}