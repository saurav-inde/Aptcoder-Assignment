import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final String lessonId;
  final bool completed;
  final DateTime completedAt;
  final List<McqProgress> mcq;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.lessonId,
    required this.completed,
    required this.completedAt,
    required this.mcq,
  });

  factory ProgressModel.fromMap(String id, Map<String, dynamic> data) {
    return ProgressModel(
      id: id,
      userId: data['user_id'] as String,
      courseId: data['courseId'] as String,
      lessonId: data['lessonId'] as String,
      completed: data['completed'] as bool,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      mcq: (data['mcq'] as List<dynamic>? ?? [])
          .map((e) => McqProgress.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'courseId': courseId,
      'lessonId': lessonId,
      'completed': completed,
      'completedAt': Timestamp.fromDate(completedAt),
      'mcq': mcq.map((e) => e.toMap()).toList(),
    };
  }
}

class McqProgress {
  final int quesSeq;
  final int chosenOption;

  McqProgress({required this.quesSeq, required this.chosenOption});

  factory McqProgress.fromMap(Map<String, dynamic> data) {
    return McqProgress(
      quesSeq: data['ques_seq'] as int,
      chosenOption: data['chosen_option'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'ques_seq': quesSeq, 'chosen_option': chosenOption};
  }
}
