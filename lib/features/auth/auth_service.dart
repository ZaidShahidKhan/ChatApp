import 'package:firebase_auth/firebase_auth.dart';

/// Service for authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Register with email and password
  Future<UserCredential> registerWithEmailPassword(
      String email,
      String password,
      String displayName,
      ) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}

// Global instance for easy access
final authService = AuthService();