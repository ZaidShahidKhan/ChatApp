import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskStatusManager {
  // Update task status
  static Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      // Update the task document with new status
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
        'isCompleted': newStatus == 'Completed',
      });

      // If needed, update project stats like completedTasks count
      final taskDoc = await FirebaseFirestore.instance.collection('tasks').doc(taskId).get();
      if (taskDoc.exists) {
        final taskData = taskDoc.data();
        final String projectId = taskData?['projectId'] ?? '';

        if (projectId.isNotEmpty) {
          await _updateProjectTaskCounts(projectId);
        }
      }
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }

  // Show task status action menu
  static Future<String?> showStatusActionMenu(BuildContext context, String currentStatus) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Update Task Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusOption(context, 'Not Started', Icons.error_outline, Colors.grey, currentStatus),
                _buildStatusOption(context, 'In Progress', Icons.timelapse, Colors.blue, currentStatus),
                _buildStatusOption(context, 'Completed', Icons.check_circle, Colors.green, currentStatus),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStatusOption(
      BuildContext context,
      String status,
      IconData icon,
      Color color,
      String currentStatus
      ) {
    final isSelected = status == currentStatus;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      tileColor: isSelected ? color.withOpacity(0.1) : null,
      onTap: () {
        Navigator.pop(context, status);
      },
    );
  }

  // Update project task counts
  static Future<void> _updateProjectTaskCounts(String projectId) async {
    try {
      // Get all tasks for this project
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();

      // Count completed tasks
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
    } catch (e) {
      print('Error updating project task counts: $e');
    }
  }
}