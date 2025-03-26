import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenz_chat/features/user/pending_approvals_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'All Users';
  String _selectedDepartment = 'All';
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).get();

      final List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'email': data['email'] ?? '',
          'department': data['department'] ?? 'Design', // Default for demo
          'role': data['role'] ?? 'member',
          'status': data['status'] ?? 'active',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
        };
      }).toList();

      setState(() {
        _users = users;
        _applyFilters();
      });
    } catch (e) {
      print('Error fetching users: $e');
      // For demo purposes, add sample users if Firebase fetch fails
      _addSampleUsers();
    }
  }


  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_users);
    filtered = filtered.where((user) => user['status'] != 'pending').toList();

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((user) {
        final fullName = '${user['firstName']} ${user['lastName']}'.toLowerCase();
        final email = user['email'].toString().toLowerCase();
        return fullName.contains(searchTerm) || email.contains(searchTerm);
      }).toList();
    }

    // Apply tab filter
    if (_selectedTab != 'All Users') {
      final tabFilter = _selectedTab.toLowerCase();
      filtered = filtered.where((user) {
        if (tabFilter == 'admins') return user['role'] == 'admin';
        if (tabFilter == 'managers') return user['role'] == 'manager';
        if (tabFilter == 'members') return user['role'] == 'member';
        return true;
      }).toList();
    }

    // Apply department filter
    if (_selectedDepartment != 'All') {
      filtered = filtered.where((user) =>
      user['department'].toString().toLowerCase() == _selectedDepartment.toLowerCase()
      ).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_ai_gradient.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildTabBar(),
              _buildDepartmentFilter(),
              _buildUserCount(),
              Expanded(
                child: _buildUserList(),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add user functionality
      //   },
      //   backgroundColor: Colors.blue[800],
      //   child: Icon(Icons.add),
      // ),
    );
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'member';
    final status = user['status'] ?? 'active';
    final department = user['department'] ?? 'Design';

    // Generate initials for avatar
    final initials = (firstName.isNotEmpty ? firstName[0] : '') +
        (lastName.isNotEmpty ? lastName[0] : '');

    // Get role badge color
    Color roleBadgeColor;
    switch (role.toLowerCase()) {
      case 'admin':
        roleBadgeColor = Color(0xFFFF9800); // Pink color
        break;
      case 'manager':
        roleBadgeColor = Color(0xFFCC4378); // Orange color
        break;
      case 'member':
        roleBadgeColor = Color(0xFF3F51B5); // Indigo color
        break;
      default:
        roleBadgeColor = Colors.grey;
    }

    // Get status badge color
    Color statusBadgeColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusBadgeColor = Colors.green;
        break;

      default:
        statusBadgeColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      color: Color(0xFF430065).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Colors.white.withOpacity(0.3), // Adjust color and opacity
          width: 1.0,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 8.0, top: 16.0, bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _getAvatarColor(initials),
              radius: 19,
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            // User info and badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDepartmentColor(department),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          department,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleBadgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _capitalizeFirst(role),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action button
            // Action button with dropdown
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white70),
              onSelected: (String value) {
                _updateUserRole(user['id'], value);
              },
              itemBuilder: (BuildContext context) => [
                if (user['role'] == 'member')
                  PopupMenuItem(
                    value: 'manager',
                    child: Text('Promote to Manager'),
                  ),
                if (user['role'] == 'manager')
                  PopupMenuItem(
                    value: 'admin',
                    child: Text('Promote to Admin'),
                  ),
                if (user['role'] == 'admin')
                  PopupMenuItem(
                    value: 'manager',
                    child: Text('Demote to Manager'),
                  ),
                if (user['role'] == 'manager')
                  PopupMenuItem(
                    value: 'member',
                    child: Text('Demote to Member'),
                  ),
              ],
            )

          ],
        ),
      ),
    );
  }
  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      // Update the role in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
      });

      // Update the local users list
      setState(() {
        // Update the user in the main users list
        _users = _users.map((user) {
          if (user['id'] == userId) {
            return {...user, 'role': newRole};
          }
          return user;
        }).toList();

        // Apply filters to refresh the filtered list
        _applyFilters();
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating role: $e');

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 2),
              Text(
                'User Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PendingApprovalsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 2, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['All Users', 'Admins', 'Managers', 'Members'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: tabs.map((tab) {
            final isSelected = _selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTab = tab;
                    _applyFilters();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFCC4378).withOpacity(0.3) : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(
                      color: Colors.white30.withOpacity(0.2),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: Align(
                    alignment: Alignment.center, // Ensures text stays vertically centered
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13, // Ensure consistent text sizing
                        height: 1.2, // Slightly adjusted for better centering
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    final departments = ['All', 'Design', 'Development', 'Product', 'Marketing', 'Sales', 'HR'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Department:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: departments.map((department) {
                final isSelected = _selectedDepartment == department;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDepartment = department;
                        _applyFilters();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected ? _getDepartmentColor(department) : Colors.transparent,
                        border: isSelected ? null : Border.all(
                          color: Colors.white30,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        department,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildUserCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        'Users (${_filteredUsers.length})',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }


  Color _getAvatarColor(String initials) {
    if (initials.isEmpty) return Colors.blueGrey;

    // Simple hash function for consistent colors
    final int hash = initials.codeUnits.fold(0, (prev, element) => prev + element);
    const colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    return colors[hash % colors.length];
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'design':
        return Colors.pink[700]!.withOpacity(0.5);
      case 'development':
        return Colors.blue[800]!.withOpacity(0.5);
      case 'product':
        return Colors.purple[700]!.withOpacity(0.5);
      case 'marketing':
        return Colors.green[700]!.withOpacity(0.5);
      case 'sales':
        return Colors.orange[700]!.withOpacity(0.6);
      case 'hr':
        return Colors.teal[700]!.withOpacity(0.5);
      case 'all':
        return Colors.grey[700]!.withOpacity(0.5);
      default:
        return Colors.blueGrey;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _addSampleUsers() {
    _users = [
      {
        'id': '1',
        'firstName': 'Alex',
        'lastName': 'Kim',
        'email': 'alex.kim@example.com',
        'department': 'Design',
        'role': 'admin',
        'status': 'active',
      },
      {
        'id': '2',
        'firstName': 'Sarah',
        'lastName': 'Johnson',
        'email': 'sarah@example.com',
        'department': 'Development',
        'role': 'manager',
        'status': 'active',
      },
      {
        'id': '3',
        'firstName': 'Mike',
        'lastName': 'Lee',
        'email': 'mike@example.com',
        'department': 'Product',
        'role': 'member',
        'status': 'active',
      },
      {
        'id': '4',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'department': 'Sales',
        'role': 'member',
        'status': 'pending',
      },
      {
        'id': '5',
        'firstName': 'Emma',
        'lastName': 'Wilson',
        'email': 'emma@example.com',
        'department': 'Design',
        'role': 'manager',
        'status': 'active',
      },
      {
        'id': '6',
        'firstName': 'David',
        'lastName': 'Chen',
        'email': 'david@example.com',
        'department': 'Development',
        'role': 'member',
        'status': 'active',
      },
      {
        'id': '7',
        'firstName': 'Lisa',
        'lastName': 'Wang',
        'email': 'lisa@example.com',
        'department': 'Marketing',
        'role': 'member',
        'status': 'active',
      },
    ];
    _applyFilters();
  }

}