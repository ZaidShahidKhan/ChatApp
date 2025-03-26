import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Update with your actual import path
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kenz_chat/features/task/tasks_tab.dart';

import '../auth/auth_service.dart';
import '../models/project.dart';
import 'create_task_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({Key? key, required this.project})
    : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
              _buildAppBar(),
              _buildProjectHeader(),
              const SizedBox(height: 0),

              _buildInfoCards(),
              _buildProgressBar(),
              const SizedBox(height: 0),

              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTasksTab(),
                    _buildTeamTab(),
                    _buildFilesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (currentUserId == widget.project.projectLeadId)? _buildFAB() : null, // Show only if project lead

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
                'Project Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: Colors.white, size: 24),
          //   onPressed: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => PendingApprovalsScreen()),
          //     // );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showDescription = !_showDescription;
              });
            },
            behavior: HitTestBehavior.opaque, // Ensures entire row is tappable
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    _showDescription ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                    size: 22, // Smaller icon
                  ),
                ),
              ],
            ),
          ),
          if (_showDescription) ...[
            const SizedBox(height: 8),
            Text(
              widget.project.description,
              style: const TextStyle(fontSize: 14, color: Color(0xE0FFFFFF)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Background Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2F45),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Active Progress with Gradient
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth * widget.project.progress,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7A00FF),
                        Color(0xFFE100FF),
                      ], // Violet gradient
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    final progressPercent = (widget.project.progress * 100).toInt();
    final formattedDate = DateFormat(
      'MMM dd, yyyy',
    ).format(widget.project.dueDate);
    final teamCount = widget.project.teamMemberDetails.length;
    final leaderInitials = widget.project.projectLeadName
        .split(' ')
        .map((e) => e[0])
        .join('');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Lead',
                  value: widget.project.projectLeadName,
                  icon: Center(
                    child: Text(
                      leaderInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  iconColor: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Team',
                  value: '$teamCount Members',
                  icon: const Icon(Icons.group, color: Colors.white, size: 18),
                  iconColor: const Color(0xFF03A9F4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Due Date',
                  value: formattedDate,
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 18,
                  ),
                  iconColor: const Color(0xFF2ECC35),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Progress',
                  value: '$progressPercent%',
                  icon: const Center(
                    child: Text(
                      '%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  iconColor: Color(0xFF7A47EF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Widget icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x416E448F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF775395), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.6),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 12), // Spacing between icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF595959), // zinc-800
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFF4F4F5), // zinc-50
                width: 2,
              ),
            ),
          ),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          labelColor: const Color(0xFFF4F4F5),
          // zinc-50
          unselectedLabelColor: const Color(0xFF71717A),
          // zinc-500
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.only(right: 24, bottom: 0, top: 10),
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Team'),
            Tab(text: 'Files'),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return TasksTab(
      projectId: widget.project.id,
      onTaskCreated: () {
        setState(() {}); // Refresh the screen
      },
      onTaskStatusChanged: () {
        setState(() {}); // Refresh the screen when task status changes
      },
    );
  }

  Widget _buildTeamTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.teamMemberDetails.length,
      itemBuilder: (context, index) {
        final member = widget.project.teamMemberDetails[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xBFFF9F9).withOpacity(0.1),
                child: Text(
                  member['name'].toString().substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      member['email'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              member['id'] == widget.project.projectLeadId
                  ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${member['name']} is driving the project forward",
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.black,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(0xC7BC2E2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Lead',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium icon with glow effect
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                  Icons.star_rate,
                color: Color(0xFFDE8EFF),
                size: 24,
              ),
            ),
            const SizedBox(height: 28),

            // Premium title
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.purple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Text(
                'Unlock Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Take your project to the next level with advanced document management and AI collaboration',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // Features list
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(Icons.description_outlined, 'Document Sharing & Collaboration'),
                  _buildDivider(),
                  _buildFeatureItem(Icons.comment_outlined, 'Real-time Comments & Feedback'),
                  _buildDivider(),
                  _buildFeatureItem(Icons.smart_toy_outlined, 'AI-Powered Document Intelligence'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Upgrade button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement subscription flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF872A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Learn more link
            TextButton(
              onPressed: () {
                // TODO: Show more details about premium features
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learn more about Premium',
                    style: TextStyle(
                      color: Colors.indigo.shade200,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Colors.indigo.shade200,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.white.withOpacity(0.1),
        height: 1,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.indigo.shade200,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "At Risk":
        return Colors.orange;
      case "On Track":
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }
  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF7A00FF), Color(0xFFE100FF)], // Violet gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          width: 44, // Smaller size
          height: 44,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTaskScreen(
                    projectId: widget.project.id, // Pass project ID here
                    onTaskCreated: () {
                      // Refresh projects
                    },
                  ),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

}
