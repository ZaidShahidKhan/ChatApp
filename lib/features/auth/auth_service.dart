import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRole {
  static const String admin = "admin";
  static const String manager = "manager";
  static const String member = "member";
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user has admin or manager role
  Future<bool> hasAdminManagerAccess() async {
    if (currentUserId == null) return false;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role'] as String?;

      return userRole == UserRole.admin || userRole == UserRole.manager;
    } catch (e) {
      print('Error checking user role: $e');
      return false;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    if (currentUserId == null) return null;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  // Modify the registerUser method in AuthService to return success without showing message

  Future<UserCredential?> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Validate inputs
      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
        _showErrorMessage(context, 'Please fill in all fields');
        return null;
      }

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _showErrorMessage(context, 'Please enter a valid email address');
        return null;
      }

      // Validate password strength (minimum 6 characters)
      if (password.length < 6) {
        _showErrorMessage(context, 'Password must be at least 6 characters long');
        return null;
      }

      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If registration successful, save additional user information
      if (userCredential.user != null) {
        // First update display name
        await userCredential.user!.updateDisplayName('$firstName $lastName');

        // Then create Firestore profile after display name is set
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'member',        // Add this line to set default role
          'status': 'pending',
        });
        await Future.delayed(const Duration(milliseconds: 500));


        // Return the credentials after everything is complete
        // NOTE: Removed success message from here to avoid duplication
        return userCredential;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      String errorMessage = 'Registration failed';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for this email';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      _showErrorMessage(context, errorMessage);
      return null;
    } catch (e) {
      // Handle other exceptions
      _showErrorMessage(context, 'Registration failed: ${e.toString()}');
      return null;
    }
  }

  // Sign in existing user
  Future<UserCredential?> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        _showErrorMessage(context, 'Please enter both email and password');
        return null;
      }

      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during login';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }

      _showErrorMessage(context, errorMessage);
      return null;
    } catch (e) {
      _showErrorMessage(context, 'Login failed: ${e.toString()}');
      return null;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper method to show error messages
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Helper method to show success messages
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}