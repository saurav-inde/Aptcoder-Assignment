class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  
  factory QuestionModel.fromMap(Map<String, dynamic> data) {
    return QuestionModel(
      question: data['question'] as String,
      options: List<String>.from(data['options'] ?? []),
      correctIndex: data['correctIndex'] as int,
    );
  }
}
