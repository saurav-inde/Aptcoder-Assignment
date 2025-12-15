import 'package:aptcoder/core/models/question.dart';

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final int sequence;
  final String type;
  final String? url;

  final List<QuestionModel>? questions;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.sequence,
    required this.type,
    this.url,
    this.questions,
  });

  factory LessonModel.fromMap(
    String id,
    String courseId,
    Map<String, dynamic> data,
  ) {
    
    List<QuestionModel>? parsedQuestions;
    if (data['questions'] != null) {
      
      
      parsedQuestions = List<Map<String, dynamic>>.from(
        data['questions'],
      ).map((questionMap) => QuestionModel.fromMap(questionMap)).toList();
    }

    return LessonModel(
      id: id,
      courseId: courseId,
      title: data['title'] as String,
      sequence: data['sequence'] as int,
      type: data['type'] as String,
      url: data['url'] as String?,
      questions: parsedQuestions, 
    );
  }
}
