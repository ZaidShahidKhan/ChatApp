import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String department;
  final String projectLeadId;
  final String projectLeadName;
  final List<String> teamMemberIds;
  final List<Map<String, dynamic>> teamMemberDetails;
  final int completedTasks;
  final int totalTasks;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final List<String> tags;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.projectLeadId,
    required this.projectLeadName,
    required this.teamMemberIds,
    required this.teamMemberDetails,
    required this.completedTasks,
    required this.totalTasks,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
    required this.tags,
  });

  // Calculate progress percentage
  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  // Determine project status based on requirements
  String get status {
    // If completedTasks === totalTasks → "Completed"
    if (completedTasks == totalTasks && totalTasks > 0) {
      return "Completed";
    }

    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    // If dueDate is within 7 days and completedTasks/totalTasks < 0.7 → "At Risk"
    if (difference <= 7 && progress < 0.7) {
      return "At Risk";
    }

    // // Custom statuses based on department (from screenshot)
    // if (department == "Engineering") {
    //   return "Phase: Development";
    // } else if (department == "Design") {
    //   return "Priority: High";
    // } else if (department == "Product") {
    //   return "Status: Verified";
    // }

    // Otherwise → "On Track"
    return "On Track";
  }

  // Factory method to create a Project from a Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      department: data['department'] ?? '',
      projectLeadId: data['projectLeadId'] ?? '',
      projectLeadName: data['projectLeadName'] ?? '',
      teamMemberIds: List<String>.from(data['teamMemberIds'] ?? []),
      teamMemberDetails: List<Map<String, dynamic>>.from(data['teamMemberDetails'] ?? []),
      completedTasks: data['completedTasks'] ?? 0,
      totalTasks: data['totalTasks'] ?? 0,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'projectLeadId': projectLeadId,
      'projectLeadName': projectLeadName,
      'teamMemberIds': teamMemberIds,
      'teamMemberDetails': teamMemberDetails,
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isArchived': isArchived,
      'tags': tags,
    };
  }
}