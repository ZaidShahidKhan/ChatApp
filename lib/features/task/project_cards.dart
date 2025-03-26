import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kenz_chat/features/models/project.dart'; // Update with your actual import path
import 'package:firebase_auth/firebase_auth.dart';

class ProjectCards extends StatelessWidget {
  final String? departmentFilter;
  final int selectedTab; // 0 = My Projects, 1 = All Projects, 2 = Archived
  final Function(Project) onProjectTap;

  const ProjectCards({
    Key? key,
    this.departmentFilter,
    required this.selectedTab,
    required this.onProjectTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Base query
    Query query = FirebaseFirestore.instance.collection('projects');

    // Apply tab filters
    switch (selectedTab) {
      case 0: // My Projects
      // Filter for projects where the current user is a member
        if (currentUserId != null) {
          query = query.where('teamMemberIds', arrayContains: currentUserId)
              .where('isArchived', isEqualTo: false);
        }
        break;
      case 1: // All Projects
        query = query.where('isArchived', isEqualTo: false);
        break;
      case 2: // Archived
        query = query.where('isArchived', isEqualTo: true);
        break;
    }

    // Apply department filter if provided
    if (departmentFilter != null && departmentFilter != 'All') {
      query = query.where('department', isEqualTo: departmentFilter);
    }

    // Sort by due date
    query = query.orderBy('dueDate', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // Adjust this value to move it lower
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers everything
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No projects found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }


        // Convert snapshots to Project objects
        final projects = snapshot.data!.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList();

        return Column(
          children: projects.map((project) => _buildProjectCard(context, project)).toList(),
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    // Calculate progress percentage for display
    final progressPercent = (project.progress * 100).toInt();

    // Get status color based on status
    final statusColor = _getStatusColor(project.status);

    // Format date
    final formattedDate = DateFormat('MMM dd').format(project.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        // color: Color(0xFF3A154A).withOpacity(0.4),
        color: Color(0xFF430065).withOpacity(0.1),
        // color: Color(0xFF431377).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),border: Border.all(
        color: Colors.white.withOpacity(0.3), // Adjust opacity as needed
        width: 1, // Adjust thickness as needed
      ),
      ),
      child: InkWell(
        onTap: () => onProjectTap(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8, left: 16, right: 4),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Title Row
            Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items properly
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures space distribution
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Aligns text and department properly
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDepartmentColor(project.department).withOpacity(0.2
                      ), // Background color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      project.department,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDepartmentColor(project.department).withOpacity(1), // Text color
                      ),
                    ),
                  ),

                ],
              ),

              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                onPressed: () => onProjectTap(project),
              ),
            ],
          ),


            const SizedBox(height: 0),

              // Lead
            Row(
              children: [
                Icon(Icons.supervisor_account_outlined, size: 16, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  'Lead: ${project.projectLeadName} ',
                  style: TextStyle(
                    fontSize: 14, // Keep lead name at 14
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  '+${project.teamMemberDetails.length -1} members',
                  style: TextStyle(
                    fontSize: 12, // Decrease team members' font size
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 12),

              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress ($progressPercent%)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ), Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${project.completedTasks}/${project.totalTasks} tasks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Due Date and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Row(
              children: [
              Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today    , size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                'Due: $formattedDate',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
        ],
      ),

        _buildStatusIndicator(project.status, statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 13,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {

      case "At Risk":
        return Color(0xFFfa9238);
      case "On Track":
        return Color(0xFF26B3DC);
      case "Completed":
        return Color(0xFF10B981);
      default:
        return Colors.blue;
    }
  }
  Color _getDepartmentColor(String departmentName) {
    const List<Map<String, dynamic>> _departments = [
      {'name': 'Engineering', 'color': Color(0xC351CDFF)},
      {'name': 'Design', 'color': Color(0xC3EA84FF)},
      {'name': 'Marketing', 'color': Color(0xC3FFA042)},
      {'name': 'Product', 'color': Color(0xC3009E91)},
    ];

    final dept = _departments.firstWhere(
          (d) => d['name'] == departmentName,
      orElse: () => {'color': Colors.grey}, // Default color if not found
    );

    return dept['color'] as Color;
  }

}