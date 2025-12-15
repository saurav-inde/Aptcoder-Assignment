import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/lesson.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewMcqScreen extends StatefulWidget {
  final LessonModel lesson;

  const ViewMcqScreen({super.key, required this.lesson});

  @override
  State<ViewMcqScreen> createState() => _ViewMcqScreenState();
}

class _ViewMcqScreenState extends State<ViewMcqScreen> {
  int _currentIndex = -1; 
  int? _selectedOption;
  final Map<int, int> _answers = {}; 

  @override
  Widget build(BuildContext context) {
    final questions = widget.lesson.questions ?? [];
    if (_currentIndex == -1) {
      
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: AppText.interLarge('MCQ Overview', weight: FontWeight.bold),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  itemCount: widget.lesson.questions?.length ?? 0,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (_, index) {
                    final answered = _answers.containsKey(index);
                    return Container(
                      decoration: BoxDecoration(
                        color: answered
                            ? primaryColor.withOpacity(0.2)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: answered ? primaryColor : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AppText.interMedium(
                        'Q${index + 1}',
                        color: answered ? primaryColor : Colors.black87,
                        weight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              AppFilledButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: 'Start Quiz',
                onTap: () => setState(() => _currentIndex = 0),
              ),
            ],
          ),
        ),
      );
    } else {
      
      final question = questions[_currentIndex];
      _selectedOption = _answers[_currentIndex];

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: AppText.interLarge(
            'Question ${_currentIndex + 1}',
            weight: FontWeight.bold,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.interMedium(question.question, weight: FontWeight.w600),
              const SizedBox(height: 24),
              ...List.generate(question.options.length, (i) {
                return RadioListTile<int>(
                  value: i,
                  groupValue: _selectedOption,
                  activeColor: primaryColor,
                  onChanged: (v) {
                    setState(() {
                      _selectedOption = v;
                      _answers[_currentIndex] = v!;
                    });
                  },
                  title: AppText.interMedium(question.options[i]),
                );
              }),
              const Spacer(),
              AppFilledButton(
                icon: Icon(
                  _currentIndex == questions.length - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                  color: Colors.white,
                ),
                label: _currentIndex == questions.length - 1
                    ? 'Submit'
                    : 'Next',
                onTap: _selectedOption == null
                    ? null
                    : () {
                        
                        _saveCurrentAnswer(context);

                        if (_currentIndex < questions.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Quiz Finished'),
                              content: Text(
                                'You answered ${_answers.length} questions',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); 
                                    Navigator.pop(context); 
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _saveCurrentAnswer(BuildContext context) {
    if (_selectedOption == null) return;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    context.read<LessonBloc>().add(
      UpdateMcqProgress(
        userId: userId,
        courseId: widget.lesson.courseId,
        lessonId: widget.lesson.id,
        quesSeq: _currentIndex + 1, 
        chosenOption: _selectedOption!,
      ),
    );
  }
}
