import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a user in the application
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final String? fcmToken;
  final Map<String, dynamic> settings;
  final List<String> activeChats;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    this.lastSeen,
    this.fcmToken,
    required this.settings,
    required this.activeChats,
  });

  /// Create a new instance from Firebase Auth data
  factory UserModel.fromFirebaseAuth({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) {
    return UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
      fcmToken: null,
      settings: {
        'darkMode': false,
        'notifications': true,
      },
      activeChats: [],
    );
  }

  /// Create an instance from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      fcmToken: data['fcmToken'],
      settings: data['settings'] as Map<String, dynamic>? ?? {
        'darkMode': false,
        'notifications': true,
      },
      activeChats: List<String>.from(data['activeChats'] ?? []),
    );
  }

  /// Convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
      'settings': settings,
      'activeChats': activeChats,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? displayName,
    String? photoURL,
    DateTime? lastSeen,
    String? fcmToken,
    Map<String, dynamic>? settings,
    List<String>? activeChats,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
      settings: settings ?? this.settings,
      activeChats: activeChats ?? this.activeChats,
    );
  }

  /// Check if dark mode is enabled in settings
  bool get isDarkModeEnabled => settings['darkMode'] == true;

  /// Check if notifications are enabled in settings
  bool get areNotificationsEnabled => settings['notifications'] == true;

  /// Get online status (considered online if last seen within 5 minutes)
  bool get isOnline {
    if (lastSeen == null) return false;
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return lastSeen!.isAfter(fiveMinutesAgo);
  }
}