import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final String assigneeName;
  final String projectId;
  final String projectTitle;
  final String priority;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.assigneeName,
    required this.projectId,
    required this.projectTitle,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
  });

  //This converts Firestore data (a DocumentSnapshot) into a Task object.
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assigneeId: data['assigneeId'] ?? '',
      assigneeName: data['assigneeName'] ?? '',
      projectId: data['projectId'] ?? '',
      projectTitle: data['projectTitle'] ?? '',
      priority: data['priority'] ?? 'Medium',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'To Do',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  //This converts the Task object back into a Firestore-compatible Map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isCompleted': isCompleted,
    };
  }
}