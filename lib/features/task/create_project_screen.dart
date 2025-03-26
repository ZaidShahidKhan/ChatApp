import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateProjectScreen extends StatefulWidget {
  final Function onProjectCreated;

  const CreateProjectScreen({Key? key, required this.onProjectCreated}) : super(key: key);

  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedDepartment;
  String? _selectedLead;
 // List<String> _selectedTags = [];
  List<String> _selectedTeamMembers = [];

  List<Map<String, dynamic>> _availableTeamMembers = [];
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = true;

  String? _selectedLeadId;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _departments = [
    {'name': 'Engineering', 'color': Colors.indigo},
    {'name': 'Design', 'color': Colors.purple},
    {'name': 'Marketing', 'color': Colors.orange},
    {'name': 'Product', 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = usersSnapshot.docs.map((doc) => {
        'id': doc.id,
        'firstName': doc.data()['firstName'],
        'lastName': doc.data()['lastName'],
        'email': doc.data()['email'] ?? '',
        'position': doc.data()['position'] ?? 'Team Member',    // Correct
        'department': doc.data()['department'] ?? 'Not Assigned', // Correct
      }).toList();

      setState(() {
        _availableUsers = users;
        _availableTeamMembers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
// Function to search users
  void _searchUsers(String query) {
    print("Searching for: $query");

    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    final filtered = _availableUsers.where((user) {
      final fullName = "${user['firstName']} ${user['lastName']}".toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      return fullName.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    print("Found ${filtered.length} results");

    setState(() {
      _isSearching = true;
      _searchResults = filtered;
    });
  }
// Helper function to get user initials
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0];
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0];
    }
    return initials.toUpperCase();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary:  Color(0x8CE1ADFF),
              onPrimary: Colors.white,
              surface: Color(0xFF2F0E40),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF151B2E),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // void _addTag() {
  //   if (_tagController.text.isNotEmpty) {
  //     setState(() {
  //       _selectedTags.add(_tagController.text);
  //       _tagController.clear();
  //     });
  //   }
  // }
  //
  // void _removeTag(String tag) {
  //   setState(() {
  //     _selectedTags.remove(tag);
  //   });
  // }

  void _createProject() async {
    try {
      final selectedUser = _availableUsers.firstWhere(
            (user) => user['id'] == _selectedLeadId,
        orElse: () => {'id': _selectedLeadId},
      );

      // Ensure project lead is included in team members
      if (_selectedLeadId != null && !_selectedTeamMembers.contains(_selectedLeadId)) {
        _selectedTeamMembers.add(_selectedLeadId!);
      }

      // Create team member details list
      final teamMemberDetails = _selectedTeamMembers.map((userId) {
        final user = _availableUsers.firstWhere(
              (u) => u['id'] == userId,
          orElse: () => {
            'id': userId,
            'firstName': 'Unknown',
            'lastName': 'User',
            'email': '',
          },
        );

        return {
          'id': userId,
          'name': "${user['firstName']} ${user['lastName']}",
          'email': user['email'] ?? '',
        };
      }).toList();

      final newProject = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'department': _selectedDepartment,
        'projectLeadId': _selectedLeadId,
        'projectLeadName': "${selectedUser['firstName']} ${selectedUser['lastName']}",
        'teamMemberIds': _selectedTeamMembers,
        'teamMemberDetails': teamMemberDetails,
        //'tags': _selectedTags,
        'dueDate': _selectedDate,
        'isArchived': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalTasks': 0,
        'completedTasks': 0,
      };

      await FirebaseFirestore.instance.collection('projects').add(newProject);

      widget.onProjectCreated();

      // Show tick GIF animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xF95B2A73),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/success_tick_purple.gif',
                      width: 100,
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Project Created Successfully!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating project: $e')),
      );
    }
  }


  bool _validateFields() {
    if (_selectedDepartment == null) {
      _showValidationError('Please select a department');
      return false;
    }

    if (_selectedLead == null) {
      _showValidationError('Please select a project lead');
      return false;
    }

    if (_selectedTeamMembers.isEmpty) {
      _showValidationError('Please add at least one team member');
      return false;
    }

    if (_selectedDate == null) {
      _showValidationError('Please select a deadline');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F0E32), // Dark purple
              Color(0xFF1F0E32), // Original background color
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildProjectTitle(),
                      const SizedBox(height: 16),
                      _buildProjectDescription(),
                      const SizedBox(height: 16),
                      _buildDepartmentSection(),
                      const SizedBox(height: 16),
                      _buildProjectLeadSection(),
                      const SizedBox(height: 16),
                      _buildTeamMembersSection(),
                      const SizedBox(height: 16),
                      _buildDeadlineSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),

                  // Astronaut GIF that moves when scrolling
                  // Positioned(
                  //   top: 10, // Adjust as needed
                  //   right: -20,
                  //   child: Transform.rotate(
                  //     angle: 0.5, // Adjust rotation as needed
                  //     child: Opacity(
                  //       opacity: 0.8, // Set opacity between 0.0 (fully transparent) to 1.0 (fully visible)
                  //       child: Image.asset(
                  //         'assets/images/astronaut.gif',
                  //         width: 120,
                  //         height: 120,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the left
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Aligns both to the left
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 0), // Adds spacing between icon and text
              const Text(
                'Create New Project',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Title',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter project title',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0x2FF8C2FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a project title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProjectDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter project description',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0x2FF8C2FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildDepartmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Department',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40, // Ensures the scroll view has a fixed height
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: Row(
              children: _departments.map((dept) {
                final bool isSelected = _selectedDepartment == dept['name'];
                final Color departmentColor = dept['color'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDepartment = dept['name'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? departmentColor.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? departmentColor : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: departmentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            dept['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildProjectLeadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Lead',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x2FF8C2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search for project lead',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white60),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchResults.clear();
                        _isSearching = false;
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  _searchUsers(value);
                },
              ),

              // Search results
              if (_isSearching && _searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        tileColor: Colors.transparent,
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withOpacity(0.7),
                          child: Text(
                            _getInitials(user['firstName'], user['lastName']),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          "${user['firstName']} ${user['lastName']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          user['email'] ?? '',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedLeadId = user['id'];
                            _searchController.text = "${user['firstName']} ${user['lastName']}";
                            _isSearching = false;
                            _searchResults.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Members',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x2FF8C2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTeamMembers.isEmpty
                        ? 'No team members added yet'
                        : 'Team members (${_selectedTeamMembers.length})',
                    style: TextStyle(
                        color: _selectedTeamMembers.isEmpty ? Colors.white54 : Colors.white70, fontSize: 16
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white70),
                    onPressed: _showTeamMemberSelector,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (_selectedTeamMembers.isNotEmpty)
                const SizedBox(height: 12),
              if (_selectedTeamMembers.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTeamMembers.map((userId) {
                    final user = _availableUsers.firstWhere(
                          (u) => u['id'] == userId,
                      orElse: () => {'firstName': 'User', 'lastName': 'Not Found'},
                    );

                    final isProjectLead = userId == _selectedLeadId;

                    return Chip(
                      backgroundColor: isProjectLead ? Colors.purple.withOpacity(0.3) : const Color(
                          0xFF154770),
                      // avatar: CircleAvatar(
                      //   backgroundColor: isProjectLead ? Colors.purple : Colors.indigo.withOpacity(0.7),
                      //   child: Text(
                      //     _getInitials(user['firstName'] ?? '', user['lastName'] ?? ''),
                      //     style: const TextStyle(color: Colors.white, fontSize: 10),
                      //   ),
                      // ),
                      label: Text(
                        '${user['firstName']} ${user['lastName']}${isProjectLead ? ' (Lead)' : ''}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                      onDeleted: isProjectLead ? null : () {
                        setState(() {
                          _selectedTeamMembers.remove(userId);
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTeamMemberSelector() {
    // Controller for the search field in the dialog
    final searchController = TextEditingController();
    List<Map<String, dynamic>> filteredUsers = List.from(_availableUsers);

    // Remove users that are already selected as team members
    filteredUsers = filteredUsers.where((user) =>
    !_selectedTeamMembers.contains(user['id'])
    ).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: const Color(0xFF540E49),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Add Team Members',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search team members...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white60),
                          fillColor: const Color(0x2FF8C2FF),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              filteredUsers = _availableUsers.where((user) =>
                              !_selectedTeamMembers.contains(user['id'])
                              ).toList();
                            } else {
                              filteredUsers = _availableUsers.where((user) {
                                final fullName = "${user['firstName']} ${user['lastName']}".toLowerCase();
                                final email = (user['email'] ?? '').toLowerCase();
                                return (fullName.contains(value.toLowerCase()) ||
                                    email.contains(value.toLowerCase())) &&
                                    !_selectedTeamMembers.contains(user['id']);
                              }).toList();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: filteredUsers.isEmpty
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No users available to add',
                              style: TextStyle(color: Colors.white60),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.withOpacity(0.7),
                                child: Text(
                                  _getInitials(user['firstName'] ?? '', user['lastName'] ?? ''),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                "${user['firstName']} ${user['lastName']}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                user['email'] ?? '',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.white70),
                                onPressed: () {
                                  this.setState(() {
                                    _selectedTeamMembers.add(user['id']);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }
  // Widget _buildTagsSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Tags',
  //         style: TextStyle(color: Colors.white70, fontSize: 14),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         decoration: BoxDecoration(
  //           color: const Color(0x2FF8C2FF),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //         child: Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: _tagController,
  //                     style: const TextStyle(color: Colors.white, fontSize: 15 ),
  //                     decoration: const InputDecoration(
  //                       hintText: 'Add tags...',
  //                       hintStyle: TextStyle(color: Colors.white54),
  //                       border: InputBorder.none,
  //                     ),
  //                     onSubmitted: (_) => _addTag(),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.add, color: Colors.white70),
  //                   onPressed: _addTag,
  //                 ),
  //               ],
  //             ),
  //             if (_selectedTags.isNotEmpty)
  //               Container(
  //                 padding: const EdgeInsets.only(top: 8, bottom: 8),
  //                 alignment: Alignment.centerLeft,
  //                 child: Wrap(
  //                   spacing: 8,
  //                   runSpacing: 8,
  //                   children: _selectedTags.map((tag) {
  //                     return Chip(
  //                       backgroundColor: const Color(0xFF007E7E),
  //                       label: Text(tag, style: const TextStyle(color: Colors.white)),
  //                       deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
  //                       onDeleted: () => _removeTag(tag),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDeadlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x2FF8C2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'dd-mm-yyyy'
                        : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.white54 : Colors.white,fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9A9A9A), // Neutral gray for subtlety
              side: const BorderSide(color: Color(0xFF818181), width: 1.4), // Darker gray for stronger contrast
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500, // More balanced weight
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: _createProject,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0x15D580FF), // Subtle purple background
              side: const BorderSide(
                color: Color(0xAAD580FF), // Soft purple outline
                width: 1.2, // Slightly thicker for premium feel
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14), // Slightly smoother
              ),
              elevation: 0, // Clean and flat design
            ),
            child: const Text(
              'Create Project',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500, // More confident text weight
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
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

        ],
      ),
    );
  }

}
