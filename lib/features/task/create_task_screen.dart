import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;
  final VoidCallback onTaskCreated;

  const CreateTaskScreen({
    Key? key,
    required this.projectId,
    required this.onTaskCreated,
  }) : super(key: key);

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedAssigneeId;
  String? _selectedAssigneeName;
  DateTime? _dueDate;
  String _priority = 'High';

  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectTeamMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjectTeamMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .get();

      if (projectDoc.exists) {
        final projectData = projectDoc.data();
        if (projectData != null && projectData.containsKey('teamMemberDetails')) {
          List<dynamic> teamDetails = projectData['teamMemberDetails'];
          _teamMembers = teamDetails.map((member) => {
            'id': member['id'],
            'name': member['name'],
            'email': member['email'],
          }).toList();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading team members: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0x8CE1ADFF), // Light purple-blue accent
              onPrimary: Colors.white, // Text on selected date
              surface: Color(0xFF2F0E40), // Calendar background
              onSurface: Colors.white, // Text color on unselected dates
            ),
            dialogBackgroundColor: const Color(0xFF151B2E), // Dark background for the dialog
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }



  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee')),
      );
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    try {
      // Get project details to include in task
      final projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .get();

      final projectData = projectDoc.data();
      final projectTitle = projectData?['title'] ?? 'Unknown Project';

      // Create a task document in the separate tasks collection
      await FirebaseFirestore.instance
          .collection('tasks')
          .add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'assigneeId': _selectedAssigneeId,
        'assigneeName': _selectedAssigneeName,
        'projectId': widget.projectId,
        'projectTitle': projectTitle,
        'priority': _priority,
        'dueDate': Timestamp.fromDate(_dueDate!),
        'status': 'To Do', // Default status
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isCompleted': false,
      });

      // Update project totalTasks count
      final projectRef = FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final projectSnapshot = await transaction.get(projectRef);
        if (!projectSnapshot.exists) {
          throw Exception("Project does not exist!");
        }

        final currentTotal = projectSnapshot.data()?['totalTasks'] ?? 0;
        transaction.update(projectRef, {'totalTasks': currentTotal + 1});
      });

      widget.onTaskCreated();




      if (mounted) {
        // Haptic feedback when dialog appears
        HapticFeedback.mediumImpact();

        // Play success sound
        //final player = AudioPlayer();
       // player.play(AssetSource('sounds/click_sound.mp3'));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GestureDetector(  // Add touch interaction

                child: AnimatedContainer(  // Add subtle animation to the container
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
                      ShaderMask(  // Add visual gradient effect to text
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Colors.white, Colors.white],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Task Created Successfully!',
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F0E32),
      appBar: null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              const Text(
                'Task Title',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0x2FF8C2FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Description',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0x2FF8C2FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Assignee
              const Text(
                'Assignee',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x2FF8C2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedAssigneeId,
                  dropdownColor: const Color(0xFF000000),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    hintText: 'Select Assignee',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: _teamMembers.map((member) {
                    return DropdownMenuItem<String>(
                      value: member['id'],
                      child: Text(member['name']),
                      onTap: () {
                        _selectedAssigneeName = member['name'];
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAssigneeId = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Due Date
              const Text(
                'Due Date',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDueDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x2FF8C2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate == null
                            ? 'dd-mm-yyyy'
                            : DateFormat('dd-MM-yyyy').format(_dueDate!),
                        style: TextStyle(
                          color: _dueDate == null ? Colors.white54 : Colors.white,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),


              // Priority
              const Text(
                'Priority',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityButton('High', Colors.redAccent),
                  const SizedBox(width: 8),
                  _buildPriorityButton('Medium', Colors.orangeAccent),
                  const SizedBox(width: 8),
                  _buildPriorityButton('Low', Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0x1E1E2E),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9A9A9A), // Neutral gray for subtlety
                  side: const BorderSide(color: Color(0xFF515151), width: 1.4), // Darker gray for contrast
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _createTask,
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
                  'Create Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500, // More confident text weight
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
  Widget _buildPriorityButton(String priority, Color dotColor) {
    final isSelected = _priority == priority;

    // Define background and border colors for each priority
    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      switch (priority) {
        case 'High':
          backgroundColor = Colors.red.withOpacity(0.2);
          borderColor = Colors.redAccent;
          break;
        case 'Medium':
          backgroundColor = Colors.orange.withOpacity(0.2);
          borderColor = Colors.orangeAccent;
          break;
        case 'Low':
          backgroundColor = Colors.blue.withOpacity(0.2);
          borderColor = Colors.blueAccent;
          break;
        default:
          backgroundColor = const Color(0xFF2D2D45);
          borderColor = Colors.indigo.withOpacity(0.7);
      }
    } else {
      backgroundColor = const Color(0x2FF8C2FF);
      borderColor = Colors.transparent;
    }

    return Expanded(
      child: GestureDetector( // Replaced InkWell to remove ripple effect
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isSelected ? 1.2 : 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                priority,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
                'Create New Task',
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

}