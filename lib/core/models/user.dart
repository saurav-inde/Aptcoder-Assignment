import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;

  
  final String? educationLevel;
  final String? fieldOfStudy;
  final String? learningGoal;

  
  final List<String> enrolledCourseIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.educationLevel,
    this.fieldOfStudy,
    this.learningGoal,
    this.enrolledCourseIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as Timestamp).toDate(),

      educationLevel: data['educationLevel'],
      fieldOfStudy: data['fieldOfStudy'],
      learningGoal: data['learningGoal'],

      enrolledCourseIds: List<String>.from(data['enrolledCourseIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),

      'educationLevel': educationLevel,
      'fieldOfStudy': fieldOfStudy,
      'learningGoal': learningGoal,

      'enrolledCourseIds': enrolledCourseIds,
    };
  }
}
