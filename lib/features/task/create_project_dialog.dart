import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateProjectDialog extends StatefulWidget {
  final Function onProjectCreated;

  const CreateProjectDialog({Key? key, required this.onProjectCreated}) : super(key: key);

  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedDepartment;
  String? _selectedLead;
  List<String> _selectedTags = [];
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
              primary: Colors.indigo,
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

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _selectedTags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _createProject() async {
    // if (_formKey.currentState!.validate() && _validateFields()) {
      try {
        final selectedUser = _availableUsers.firstWhere(
              (user) => user['id'] == _selectedLeadId,
          orElse: () => {'id': _selectedLeadId},
        );
        // Make sure project lead is included in team members
        if (_selectedLeadId != null && !_selectedTeamMembers.contains(_selectedLeadId)) {
          _selectedTeamMembers.add(_selectedLeadId!);
        }

        // Create team member details list for Firestore
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
         'projectLeadId': _selectedLeadId,  // Change from _selectedLead to _selectedLeadId
         'projectLeadName': "${selectedUser['firstName']} ${selectedUser['lastName']}",
          'teamMemberIds': _selectedTeamMembers, // Store just the IDs for references
          'teamMemberDetails': teamMemberDetails, //
          'tags': _selectedTags,
          'dueDate': _selectedDate,
          'isArchived': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'totalTasks': 0,
          'completedTasks': 0,
        };

        await FirebaseFirestore.instance.collection('projects').add(newProject);

        widget.onProjectCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 3), // Reduce height
              child: const Text(
                'Project created successfully!',
                style: TextStyle(fontSize: 14), // Smaller font for compact look
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Makes it less intrusive
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adds spacing
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Smooth edges
            ),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating project: $e')),
        );
      }
    // }
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
    final double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent, // Make background transparent
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: screenWidth * 1, // Ensure width is applied
        child: Container(
          width: double.infinity, // Take full `SizedBox` width
          constraints: const BoxConstraints(maxWidth: 800), // Max width limit
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF210C3A), // Dark purple
                Color(0xFF3E0F5A), // Original background color
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)), // Match dialog shape
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildDeadlineSection(),
                  const SizedBox(height:24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Add an illustration here
        Container(
          width: double.infinity, // Make it take full width
          height: 160, // Set an appropriate height
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/project_creation.jpg'),
              fit: BoxFit.cover, // Cover the entire space
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Create New Project',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
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
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0x32FFFFFF),
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
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0x32FFFFFF),
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
            color: const Color(0x32FFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search for project lead',
                  hintStyle: const TextStyle(color: Colors.white38),
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
            color: const Color(0x32FFFFFF),
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
                      color: _selectedTeamMembers.isEmpty ? Colors.white38 : Colors.white70, fontSize: 15
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
                          0xFF531985),
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
                backgroundColor: const Color(0xFF2D0B44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: Colors.white60),
                          fillColor: const Color(0x32FFFFFF),
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
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
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
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x32FFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: const TextStyle(color: Colors.white, fontSize: 14 ),
                      decoration: const InputDecoration(
                        hintText: 'Add tags...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white70),
                    onPressed: _addTag,
                  ),
                ],
              ),
              if (_selectedTags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedTags.map((tag) {
                      return Chip(
                        backgroundColor: const Color(0xFF1C4A1B),
                        label: Text(tag, style: const TextStyle(color: Colors.white)),
                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

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
              color: const Color(0x32FFFFFF),
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
                      color: _selectedDate == null ? Colors.white38 : Colors.white,
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: _createProject,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            backgroundColor: const Color(0x15D580FF), // Very subtle purple background
            side: const BorderSide(
              color: Color(0xAAD580FF), // Light, subtle purple
              width: 1.0, // Thin, elegant border
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // Pill-shaped
            ),
            elevation: 0,
          ),
          child: const Text(
            'Create Project',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400, // Lighter weight
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }


}
