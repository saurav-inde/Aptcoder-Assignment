import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/apptextformfield.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/state/admin_course_mgt.dart';
import 'package:aptcoder/state/admin_lesson_mgt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMcqLessonScreen extends StatefulWidget {
  final String courseId;

  const AddMcqLessonScreen({super.key, required this.courseId});

  @override
  State<AddMcqLessonScreen> createState() => _AddMcqLessonScreenState();
}

class _AddMcqLessonScreenState extends State<AddMcqLessonScreen> {
  final _titleController = TextEditingController();
  final _sequenceController = TextEditingController();

  final List<_McqForm> _questions = [_McqForm()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText.interLarge('Add MCQ Lesson', weight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AdminLessonBloc, AdminCourseState>(
        listener: (context, state) {
          if (state is AdminCourseSuccess) {
            Navigator.pop(context);
          }
          if (state is AdminCourseFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppTextFormField(
                controller: _titleController,
                label: 'Lesson Title',
                hint: 'Enter MCQ lesson title',
              ),

              const SizedBox(height: 12),

              AppTextFormField(
                controller: _sequenceController,
                label: 'Sequence',
                hint: 'Lesson order',
              ),

              const SizedBox(height: 24),

              AppText.interLarge('Questions', weight: FontWeight.w600),

              const SizedBox(height: 12),

              ..._questions.asMap().entries.map(
                (entry) => _McqCard(
                  index: entry.key,
                  form: entry.value,
                  onDelete: _questions.length > 1
                      ? () => setState(() => _questions.removeAt(entry.key))
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => setState(() => _questions.add(_McqForm())),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: AppText.interMedium(
                    '+ Add Question',
                    color: primaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              AppFilledButton(
                icon: const Icon(Icons.check, color: Colors.white),
                label: 'Create MCQ Lesson',
                onTap: state is AdminCourseSubmitting ? null : _submitMcqLesson,
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitMcqLesson() {
    if (_titleController.text.isEmpty || _sequenceController.text.isEmpty)
      return;

    final questions = _questions.map((q) => q.toMap()).toList();

    context.read<AdminLessonBloc>().add(
      CreateLessonEvent(
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        sequence: int.parse(_sequenceController.text),
        type: 'mcq',
        questions: questions,
      ),
    );
  }
}

class _McqCard extends StatefulWidget {
  final int index;
  final _McqForm form;
  final VoidCallback? onDelete;

  const _McqCard({required this.index, required this.form, this.onDelete});

  @override
  State<_McqCard> createState() => _McqCardState();
}

class _McqCardState extends State<_McqCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.interMedium(
                'Question ${widget.index + 1}',
                weight: FontWeight.w600,
              ),
              const Spacer(),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
            ],
          ),

          AppTextFormField(
            controller: widget.form.question,
            label: 'Question',
            hint: 'Enter question',
          ),

          const SizedBox(height: 12),

          ...List.generate(4, (i) {
            return RadioListTile<int>(
              value: i,
              groupValue: widget.form.correctIndex,
              activeColor: primaryColor,
              onChanged: (v) => widget.form.correctIndex = v!,
              title: AppTextFormField(
                controller: widget.form.options[i],
                label: 'Option ${i + 1}',
                hint: 'Enter option',
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _McqForm {
  final question = TextEditingController();
  final options = List.generate(4, (_) => TextEditingController());
  int correctIndex = 0;

  Map<String, dynamic> toMap() {
    return {
      'question': question.text.trim(),
      'options': options.map((e) => e.text.trim()).toList(),
      'correctIndex': correctIndex,
    };
  }
}
