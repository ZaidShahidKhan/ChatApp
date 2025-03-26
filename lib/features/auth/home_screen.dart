import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kenz_chat/features/ai/ai_screen.dart';
import 'package:kenz_chat/features/task/project_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../shared/common_widgets.dart';
import '../../theme.dart';
import '../chat/chat_screen.dart';
import '../call/call_screen.dart';
import '../profile/profile_screen.dart';
import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final authService = AuthService();  // Create instance of AuthService
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String _userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get current user and their display name
  Future<void> _getCurrentUser() async {
    setState(() {
      _currentUser = _auth.currentUser;  // Get current logged-in user
      if (_currentUser != null) {
        // Use display name if available, otherwise use email
        _userName = _currentUser!.displayName ?? _currentUser!.email ?? "Logged In User";
        print("Current user: $_userName"); // Debug print
      } else {
        _userName = "Not logged in";
        print("No user is logged in"); // Debug print
      }
    });
  }

  final List<Widget> _screens = [
    const ChatScreen(),
    const ProjectScreen(),
    const AiScreen(),
    const ProfileScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF390962),
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        // backgroundColor: Color(0xFF192150),
        backgroundColor: Color(0xFF000000),
        title: Text(
          "Welcome, $_userName",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showSignOutDialog(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Color(0xFFC6C6CF),
        unselectedItemColor: Color(0xFF888888),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            title: const Text("Chats"),
            selectedColor: Color(0xFFC6C6CF),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.checklist),
            title: const Text("Tasks"),
            selectedColor: Color(0xFFC6C6CF),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.memory_outlined),
            title: const Text("AI"),
            selectedColor: Color(0xFFC6C6CF),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.people_outline),
            title: const Text("Contacts"),
            selectedColor: Color(0xFFC6C6CF),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text("Profile"),
            selectedColor: Color(0xFFC6C6CF),
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
            onPressed: () async {
              // Sign out
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              // You might want to navigate to login screen here
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}