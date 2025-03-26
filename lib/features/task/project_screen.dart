import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kenz_chat/features/task/project_cards.dart';
import 'package:kenz_chat/features/task/project_details_screen.dart';

import 'package:kenz_chat/features/user/user_list_screen.dart';
import 'dart:ui';

import '../auth/auth_service.dart';
import '../auth/pending_screen.dart';
import 'create_project_dialog.dart';
import 'create_project_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  int _selectedIndex = 0;
  final tabs = ["My Projects", "All Projects", "Archived"];
  final departments = ["All", "Engineering", "Design", "Marketing", "Product"];
  int selectedDepartment = 0;
  bool _hasAdminAccess = false;
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final hasAccess = await _authService.hasAdminManagerAccess();
    setState(() {
      _hasAdminAccess = hasAccess;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Container(
      //   decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [Color(0xFF192150), Color(0xFF390962)], // Updated gradient as requested
      //     ),
      //   ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_ai_gradient.jpg'),
            // Replace with your image path
            fit: BoxFit.cover, // This will cover the entire container
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1, 0, 1, 1),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildProjectTabs(),
                        const SizedBox(height: 16),
                        _buildDepartmentFilter(),
                        const SizedBox(height: 4),
                        if (_selectedIndex == 1) ...[
                          const SizedBox(height: 16),
                          _buildStatusCards(),
                        ],
                        const SizedBox(height: 16),
                        // Second status card removed as requested
                        _buildActiveProjectsHeader(),
                        ProjectCards(
                          departmentFilter:
                              selectedDepartment == 0
                                  ? null
                                  : departments[selectedDepartment],
                          onProjectTap: (project) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProjectDetailScreen(project: project),
                              ),
                            );
                          },
                          selectedTab: _selectedIndex,
                        ),

                        // const SizedBox(height: 16),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   child: ProjectsList(
                        //  //   projects: _filteredProjects,
                        //     onProjectTap: (projectId) {
                        //       // Navigate to project details
                        //       // Navigator.of(context).push(
                        //       //   MaterialPageRoute(
                        //       //     builder: (context) =>
                        //       //         ProjectDetailsScreen(projectId: projectId),
                        //       //   ),
                        //       // );
                        //     },
                        //   ),
                        // ),
                        // Active projects cards excluded as requested
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Text(
            'Projects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF243077),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const ProjectCountWidget(),
          ),
          const Spacer(),

          // User management button - only visible for admin/manager
          if (_hasAdminAccess)
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.supervisor_account,
                  color: Colors.white,
                  size: 18,
                ),
                tooltip: "User Management",
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

          if (_hasAdminAccess) const SizedBox(width: 8),

          // New Project Button - only visible for admin/manager
          if (_hasAdminAccess)
            ElevatedButton.icon(
              onPressed: () {
                // showDialog(
                //   context: context,
                //   builder: (context) =>
                //       CreateProjectDialog(
                //         onProjectCreated: () {
                //           // Refresh your projects list or perform other actions
                //          // fetchProjects();
                //         },
                //       ),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateProjectScreen(
                          onProjectCreated: () {
                            // Refresh projects
                          },
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                "New Project",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              decoration: InputDecoration(
                hintText: 'Search projects...',
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

  Widget _buildProjectTabs() {
    return Container(
      width: double.infinity,
      // Fill the width of the parent
      alignment: Alignment.centerLeft,
      // Align the child (SingleChildScrollView) to the left
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero, // Ensure no padding
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // Explicitly start from the left
            children: List.generate(
              tabs.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == index
                            ? const Color(0xFFCC4378).withOpacity(0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        _selectedIndex != index
                            ? Border.all(color: Colors.white.withOpacity(0.2))
                            : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
          child: const Text(
            'Filter by Department:',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
            child: Row(
              children: List.generate(
                departments.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDepartment = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedDepartment == index
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selectedDepartment == index
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      departments[index],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards() {
    return const ProjectStatusCounts();
  }

  Widget _buildGlassmorphicStatusCard({
    required String title,
    required int count,
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      // Use the icon color with opacity
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'projects',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveProjectsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 2 ? 'Archived Projects' : 'Active Projects',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectStatusCounts extends StatelessWidget {
  const ProjectStatusCounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('projects')
              .where('isArchived', isEqualTo: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 108,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildDefaultStatusCards();
        }

        // Count projects by status
        int onTrackCount = 0;
        int atRiskCount = 0;
        int completedCount = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Extract necessary fields
          final completedTasks = data['completedTasks'] ?? 0;
          final totalTasks = data['totalTasks'] ?? 0;
          final dueDate =
              (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          final department = data['department'] ?? '';

          // Calculate progress
          final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

          // Determine status using same logic as Project model
          if (completedTasks == totalTasks && totalTasks > 0) {
            completedCount++;
          } else {
            final now = DateTime.now();
            final difference = dueDate.difference(now).inDays;

            if (difference <= 7 && progress < 0.7) {
              atRiskCount++;
            } else {
              onTrackCount++;
            }
          }
        }

        return SizedBox(
          height: 108,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
              child: Row(
                children: [
                  _buildGlassmorphicStatusCard(
                    title: 'On Track',
                    count: onTrackCount,
                    cardColor: const Color(0xFF243077),
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFF6796DD),
                  ),
                  const SizedBox(width: 10),
                  _buildGlassmorphicStatusCard(
                    title: 'At Risk',
                    count: atRiskCount,
                    cardColor: const Color(0xFF573046),
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 10),
                  _buildGlassmorphicStatusCard(
                    title: 'Success',
                    count: completedCount,
                    cardColor: const Color(0xFF0E4947),
                    icon: Icons.check,
                    iconColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultStatusCards() {
    return SizedBox(
      height: 108,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 2, 2),
          child: Row(
            children: [
              _buildGlassmorphicStatusCard(
                title: 'On Track',
                count: 0,
                cardColor: const Color(0xFF243077),
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF6796DD),
              ),
              const SizedBox(width: 10),
              _buildGlassmorphicStatusCard(
                title: 'At Risk',
                count: 0,
                cardColor: const Color(0xFF573046),
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              _buildGlassmorphicStatusCard(
                title: 'Success',
                count: 0,
                cardColor: const Color(0xFF0E4947),
                icon: Icons.check,
                iconColor: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildGlassmorphicStatusCard({
  required String title,
  required int count,
  required Color cardColor,
  required IconData icon,
  required Color iconColor,
}) {
  // Determine if we should use singular or plural form
  final projectText = count == 1 ? 'project' : 'projects';

  return Container(
    width: 150,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              projectText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class ProjectCountWidget extends StatelessWidget {
  const ProjectCountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('projects')
              .where('isArchived', isEqualTo: false)
              .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF243077),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count Active',
            style: const TextStyle(
              color: Color(0xFFB2BCFF),
              fontSize: 12,
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
        );
      },
    );
  }
}

// void main() {

//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Project Dashboard',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         fontFamily: 'Inter',
//       ),
//       home: const ProjectScreen(),
//     );
//   }
// }
