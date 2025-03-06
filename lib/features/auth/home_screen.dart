// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../shared/common_widgets.dart';
import '../../theme.dart';
import '../chat/chat_screen.dart';
import '../call/call_screen.dart';
import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final authService = AuthService(); // Make sure this is properly initialized

  final List<Widget> _screens = [
    const ChatScreen(), // No longer needs client param
    const CallScreen(),
    const Placeholder(), // Replace with contacts screen when available
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // appBar: AppBar(
      //   title: const Text('Chat App'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () => _showSignOutDialog(context),
        //     tooltip: 'Sign Out',
        //   ),
      //   // ],
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            title: const Text("Chats"),
            selectedColor: Colors.blue, // Use AppColors.secondary if available
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.call_outlined),
            title: const Text("Calls"),
            selectedColor: Colors.blue, // Use AppColors.secondary if available
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.people_outline),
            title: const Text("Contacts"),
            selectedColor: Colors.blue, // Use AppColors.secondary if available
          ),
        ],
      ),
    );
  }

  // Show sign out confirmation dialog
  Future<void> _showSignOutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Sign out
              authService.signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}