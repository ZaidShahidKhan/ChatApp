import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TasksTab extends StatefulWidget {
  final String projectId;
  final VoidCallback onTaskCreated;
  final VoidCallback onTaskStatusChanged;


  const TasksTab({
    Key? key,
    required this.projectId,
    required this.onTaskCreated,
    required this.onTaskStatusChanged,
  }) : super(key: key);

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'My Tasks', 'Completed', 'In Progress', 'Not Started', 'On Hold'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8,),
        _buildFilterBar(),
    //    SizedBox(height: 8,),
        Expanded(
          child: _buildTasksList(),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          final filterColor = _getFilterColor(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filterColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: filterColor.withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: (filter == 'Not Started' || filter == 'On Hold' ||  filter == 'Completed' || filter == 'All') && isSelected
                        ? Colors.white // Force white text for Not Started and On Hold
                        : isSelected
                        ? _getReadableTextColor(filterColor)
                        : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // Function to get filter colors
  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'My Tasks':
        return Color(0xFFFC06E8);
      case 'Completed':
        return Colors.green.shade400;
      case 'In Progress':
        return Colors.blue.shade400;
      case 'On Hold':
        return Colors.orange.shade400;
      case 'Not Started':
        return Colors.grey.shade400;

      default:
        return Color(0xFFFC06E8); // All filter
    }
  }

  // Ensures readable text color based on background brightness
  Color _getReadableTextColor(Color backgroundColor) {
    double brightness = (0.299 * backgroundColor.red +
        0.587 * backgroundColor.green +
        0.114 * backgroundColor.blue); // Luminance formula
    return brightness > 150 ? Colors.black : Colors.white;
  }

  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: widget.projectId)
          .orderBy('dueDate', descending: true) // later add sorting with dueDate
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tasks: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final tasks = snapshot.data?.docs ?? [];
        if (tasks.isEmpty)  {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFilterEmptyIcon(_selectedFilter), // Use the filter-specific icon
                  color: Color(0xFFFFFFF).withOpacity(0.4),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_selectedFilter.toLowerCase()} tasks found',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }
        // Filter tasks based on selected filter
        final filteredTasks = tasks.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Not Started';

          switch (_selectedFilter) {
            case 'My Tasks':
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              return data['assigneeId'] == currentUserId;
            case 'Completed':
              return status == 'Completed';
            case 'In Progress':
              return status == 'In Progress';
            case 'Not Started':
              return status == 'Not Started' || status == 'To Do';
            case 'On Hold':
              return status == 'On Hold';
            default:
              return true; // 'All' filter
          }
        }).toList();


        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final taskDoc = filteredTasks[index];
            final taskData = taskDoc.data() as Map<String, dynamic>;

            return _buildTaskCard(taskDoc.id, taskData);
          },
        );
      },
    );
  }
  IconData _getFilterEmptyIcon(String filter) {
    switch (filter) {
      case 'My Tasks':
        return Icons.push_pin_rounded;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'In Progress':
        return Icons.loop_rounded; // Circular progress effect
      case 'Not Started':
        return Icons.schedule_outlined; // Clock for pending tasks
      case 'On Hold':
        return Icons.pause_circle_outline;
      case 'All':
        return Icons.dashboard_rounded; // Grid-style overview icon
      default:
        return Icons.task_alt_rounded; // General task icon
    }
  }

  Widget _buildTaskCard(String taskId, Map<String, dynamic> taskData) {
    final String title = taskData['title'] ?? 'Untitled Task';
    final String assigneeName = taskData['assigneeName'] ?? 'Unassigned';
    final String assigneeId = taskData['assigneeId'] ?? '';
    final String priority = taskData['priority'] ?? 'Medium';
    final String status = taskData['status'] ?? 'Not Started';
    final Timestamp dueDateTimestamp = taskData['dueDate'] ?? Timestamp.now();
    final DateTime dueDate = dueDateTimestamp.toDate();
    final String formattedDate = DateFormat('MMM d').format(dueDate);

    IconData statusIcon;
    Color statusIconColor;
    Color statusBackgroundColor;

    switch (status) {
      case 'Completed':
        statusIcon = Icons.task_alt_rounded;
        statusIconColor = Colors.green.shade700;
        statusBackgroundColor = Colors.green.withOpacity(0.15);
        break;
      case 'In Progress':
        statusIcon = Icons.access_time_outlined;
        statusIconColor = Colors.blue.shade400;
        statusBackgroundColor = Colors.blue.withOpacity(0.15);
        break;
      case 'On Hold':
        statusIcon = Icons.pause_circle_outline;
        statusIconColor = Colors.amber.shade700;
        statusBackgroundColor = Colors.amber.withOpacity(0.15);
        break;
      case 'Blocked':
        statusIcon = Icons.block_outlined;
        statusIconColor = Colors.red.shade400;
        statusBackgroundColor = Colors.red.withOpacity(0.15);
        break;
      default:
        statusIcon = Icons.error_outline;
        statusIconColor = Colors.grey.shade500;
        statusBackgroundColor = Colors.grey.withOpacity(0.15);
    }

    // Get current user to check if they are the assignee or project lead
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isAssignee = currentUserId == assigneeId;
    // We'll check if user is project lead in the InkWell onTap below

    return InkWell(
      onTap: () async {
        // Check if current user is assignee or project lead before showing dialog
        if (isAssignee) {
          // User is assignee, show status change dialog
          _showStatusChangeDialog(context, taskId, status);
        } else {
          // Check if user is project lead
          final projectDoc = await FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectId)
              .get();

          if (projectDoc.exists) {
            final projectData = projectDoc.data();
            final projectLeadId = projectData?['projectLeadId'];

            if (currentUserId == projectLeadId) {
              // User is project lead, show status change dialog
              _showStatusChangeDialog(context, taskId, status);
            } else {
              // User is neither assignee nor project lead, show message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only the assignee or project lead can update task status'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      },
      child: Stack(
        children: [
          // Glassmorphic Background
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02), // Adjust transparency
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)), // Border for depth
                ),
                padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16, right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for status icon and title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular status icon background
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(statusIcon, color: statusIconColor, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2), // Adds top margin

                              child: Row(
                                children: [
                                  _buildLabel(priority, _getPriorityColor(priority)), // Use regular label for priority
                                  const SizedBox(width: 6),
                                  _buildStatusLabel(status, _getStatusColor(status)), // Use dot label for status
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Assignee and date row
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes items apart
                        children: [
                          Row( // Left side content
                            children: [
                              Text(assigneeName, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              const SizedBox(width: 6),
                              Text('•', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                              const SizedBox(width: 6),
                              Text(formattedDate, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                            ],
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white60, size: 20), // Moves to the far right
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// Enhanced label with dot for status
  Widget _buildStatusLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filled dot
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ) ,
          ),
          const SizedBox(width: 6),
          // Status text
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return Colors.orange.shade400;
      case 'Low':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade400;
      case 'In Progress':
        return Colors.blue.shade400;
      case 'On Hold':
        return Colors.orange.shade400;
      case 'Not Started':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  void _showStatusChangeDialog(BuildContext context, String taskId, String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.6),
                    Colors.indigo.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Update Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusOptionSelectable(
                    context,
                    'Completed',
                    Icons.task_alt_rounded,
                    Colors.green.shade400,
                    selectedStatus,
                        (status) => setState(() => selectedStatus = status),
                  ),
                  _buildStatusOptionSelectable(
                    context,
                    'In Progress',
                    Icons.access_time_outlined,
                    Colors.blue.shade400,
                    selectedStatus,
                        (status) => setState(() => selectedStatus = status),
                  ),
                  _buildStatusOptionSelectable(
                    context,
                    'Not Started',
                    Icons.error_outline,
                    Colors.grey.shade400,
                    selectedStatus,
                        (status) => setState(() => selectedStatus = status),
                  ),
                  _buildStatusOptionSelectable(
                    context,
                    'On Hold',
                    Icons.pause_circle_outline,
                    Colors.orange.shade400,
                    selectedStatus,
                        (status) => setState(() => selectedStatus = status),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Update button
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);

                          if (selectedStatus != currentStatus) {
                            try {
                              await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
                                'status': selectedStatus,
                                'updatedAt': Timestamp.now(),
                                'isCompleted': selectedStatus == 'Completed',
                              });

                              // Update project stats
                              _updateProjectTaskCounts(widget.projectId);

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task status updated to $selectedStatus'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: _getStatusColor(selectedStatus).withOpacity(0.8),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating task: $e'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: (selectedStatus != currentStatus)
                                ? _getStatusColor(selectedStatus)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildStatusOptionSelectable(
      BuildContext context,
      String status,
      IconData icon,
      Color color,
      String selectedStatus,
      Function(String) onStatusSelected,
      ) {
    final bool isSelected = status == selectedStatus;

    return GestureDetector(
      onTap: () => onStatusSelected(status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              status,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProjectTaskCounts(String projectId) async {
    try {
      // Get all tasks for this project
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();

      // Count total and completed tasks
      final totalTasks = tasksSnapshot.docs.length;
      final completedTasks = tasksSnapshot.docs
          .where((doc) => (doc.data()['status'] == 'Completed'))
          .length;

      // Update project document
      await FirebaseFirestore.instance.collection('projects').doc(projectId).update({
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'updatedAt': Timestamp.now(),
      });
      widget.onTaskCreated();
    } catch (e) {
      debugPrint('Error updating project task counts: $e');
    }
  }
}