import 'package:flutter/material.dart';

class EmptyLessonScreen extends StatelessWidget {
  final String title;
  final String message;

  const EmptyLessonScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
