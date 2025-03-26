import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:kenz_chat/features/auth/pending_screen.dart';

import 'home_screen.dart';


class UserStatusRouter extends StatelessWidget {
  const UserStatusRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userStatus = userData['status'] as String?;

          if (userStatus == 'pending') {
            return const PendingScreen();
          } else if (userStatus == 'active') {
            return const HomeScreen();
          } else {
            // Default case
            return const HomeScreen();
          }
        }

        // If user document doesn't exist
        return const HomeScreen();
      },
    );
  }
}