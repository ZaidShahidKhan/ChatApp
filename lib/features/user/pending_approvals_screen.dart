import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();

      final List<Map<String, dynamic>> pendingUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'email': data['email'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'status': data['status'] ?? 'pending',
        };
      }).toList();

      setState(() {
        _pendingUsers = pendingUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching pending users: $e');
      // Add sample data for demo
      _addSamplePendingUsers();
      setState(() {
        _isLoading = false;
      });
    }
  }


  String _getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  Future<void> _approveUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': 'active'});

      // Remove from local list
      setState(() {
        _pendingUsers.removeWhere((user) => user['id'] == userId);
      });
    } catch (e) {
      print('Error approving user: $e');
      // For demo, just remove from the list
      setState(() {
        _pendingUsers.removeWhere((user) => user['id'] == userId);
      });
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();

      // Remove from local list
      setState(() {
        _pendingUsers.removeWhere((user) => user['id'] == userId);
      });
    } catch (e) {
      print('Error rejecting user: $e');
      // For demo, just remove from the list
      setState(() {
        _pendingUsers.removeWhere((user) => user['id'] == userId);
      });
    }
  }

  Future<void> _approveAll() async {
    final batch = FirebaseFirestore.instance.batch();

    try {
      // In a real app, use a batch write
      for (var user in _pendingUsers) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user['id']);
        batch.update(docRef, {'status': 'active'});
      }

      await batch.commit();

      // Clear the list after approval
      setState(() {
        _pendingUsers = [];
      });
    } catch (e) {
      print('Error approving all users: $e');
      // For demo, just clear the list
      setState(() {
        _pendingUsers = [];
      });
    }
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
            children: [
              _buildHeader(),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _pendingUsers.isEmpty
                  ? _buildEmptyState()
                  : Expanded(
                child: Column(
                  children: [
                    _buildWarningBanner(),
                    SizedBox(height: 12,),
                    Expanded(
                      child: _buildPendingList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                'Pending Approvals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list, color: Colors.white, size: 22),
          //   onPressed: () {
          //     // Filter functionality
          //   },
          // ),
        ],
      ),
    );
  }


  Widget _buildPendingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      itemCount: _pendingUsers.length,
      itemBuilder: (context, index) {
        final user = _pendingUsers[index];
        return _buildPendingUserCard(user);
      },
    );
  }

  Widget _buildPendingUserCard(Map<String, dynamic> user) {
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final email = user['email'] ?? '';
    final createdAt = user['createdAt'] as Timestamp;
    final initials = (firstName.isNotEmpty ? firstName[0] : '') +
        (lastName.isNotEmpty ? lastName[0] : '');

    return Container(
      margin: EdgeInsets.only(bottom: 14.0),
      padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF430065).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with initials
          CircleAvatar(
            backgroundColor: _getAvatarColor(initials),
            radius: 18,
            child: Text(
              initials.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 16),

          // User info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6), // Spacing before Time Ago
                Text(
                  _getTimeAgoSentence(createdAt),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Approve & Reject buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildActionButton(Icons.check, Colors.green, () => _approveUser(user['id'])),
              SizedBox(width: 12),
              _buildActionButton(Icons.close, Colors.red, () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Color(0xFF3E131A).withOpacity(1),
                      title: Text(
                        'Reject User?',
                        style: TextStyle(color: Colors.white, fontSize: 18,),
                      ),
                      content: Text(
                        'Are you sure you want to reject this user? This action is permanent and cannot be undone.',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Yes', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _rejectUser(user['id']);
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
  void _addSamplePendingUsers() {
    final now = DateTime.now();

    _pendingUsers = [
      {
        'id': '1',
        'firstName': 'Priya',
        'lastName': 'Patel',
        'email': 'ppatel@example.com',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(minutes: 10))),
        'status': 'pending',
      },
      {
        'id': '2',
        'firstName': 'James',
        'lastName': 'Davis',
        'email': 'james.d@example.com',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(hours: 2))),
        'status': 'pending',
      },
      {
        'id': '3',
        'firstName': 'Emma',
        'lastName': 'Wilson',
        'email': 'e.wilson@example.com',
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 1))),
        'status': 'pending',
      },
    ];
  }

// ✅ Generates natural language time ago sentences
  String _getTimeAgoSentence(Timestamp timestamp) {
    final now = DateTime.now();
    final createdAt = timestamp.toDate();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return "Joined just now";
    if (difference.inMinutes < 60) return "Joined ${difference.inMinutes} minutes ago";
    if (difference.inHours < 24) return "Joined ${difference.inHours} hours ago";
    if (difference.inDays == 1) return "Joined yesterday";
    return "Joined ${difference.inDays} days ago";
  }

  Widget _buildWarningBanner() {
    final pendingCount = _pendingUsers.length;
    final userText = pendingCount == 1 ? 'user' : 'users';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Color(0xFFBA9B00).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(  // Prevents text overflow
            child: Text(
              '$pendingCount $userText waiting for approval',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // Prevents breaking UI
              maxLines: 1,
            ),
          ),
          SizedBox(width: 8), // Adds spacing before the button
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor:Color(0xFF322B18).withOpacity(1),
                    title: Text(
                      'Approve All Users?',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    content: Text(
                      'This will approve all pending users at once. This action cannot be undone. Do you still want to proceed?',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text('Yes', style: TextStyle(color: Color(0xFFECB900).withOpacity(0.9))),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _approveAll();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFECB900).withOpacity(0.9),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Approve All',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),

        ],
      ),
    );
  }


// Extracted action button builder
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.withOpacity(0.7),
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              'No pending approvals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All user requests have been processed',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String initials) {
    if (initials.isEmpty) return Colors.blueGrey;

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
}