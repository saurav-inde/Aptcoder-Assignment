import 'dart:io';
import 'dart:typed_data';

import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/apptextformfield.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/state/admin_course_mgt.dart';
import 'package:aptcoder/state/admin_lesson_mgt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddLessonBottomSheet extends StatefulWidget {
  final String courseId;

  const AddLessonBottomSheet({super.key, required this.courseId});

  @override
  State<AddLessonBottomSheet> createState() => _AddLessonBottomSheetState();
}

class _AddLessonBottomSheetState extends State<AddLessonBottomSheet> {
  final _titleController = TextEditingController();
  final _sequenceController = TextEditingController();

  final videoUrlController = TextEditingController();

  String _selectedType = 'video';

  Uint8List? _fileBytes;
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: BlocConsumer<AdminLessonBloc, AdminCourseState>(
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              AppText.interLarger('Add New Lesson', weight: FontWeight.bold),

              const SizedBox(height: 16),

              AppTextFormField(
                controller: _titleController,
                label: 'Lesson Title',
                hint: 'Enter lesson title',
              ),

              const SizedBox(height: 12),

              /// Sequence
              AppTextFormField(
                controller: _sequenceController,

                label: 'Sequence',
                hint: 'Lesson order (e.g. 1)',
              ),

              const SizedBox(height: 16),

              /// Lesson Type
              _FieldLabel('Lesson Type'),
              const SizedBox(height: 8),
              Row(
                children: ['video', 'pdf', 'ppt'].map((type) {
                  final selected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? primaryColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? primaryColor
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AppText.interMedium(
                          type.toUpperCase(),
                          weight: FontWeight.w600,
                          color: selected ? primaryColor : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// File Picker Placeholder
              if (_selectedType != 'mcq' && _selectedType != 'video')
                GestureDetector(
                  onTap: () async {
                    final pickerResult = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                    );
                    if (pickerResult?.files.isNotEmpty ?? false) {
                      final path = pickerResult!.files.first.path;
                      if (path != null) {
                        final bytes = await File(path).readAsBytes();
                        _fileBytes = bytes;
                        _fileName = path.split('/').last;
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText.interSmall(
                            _fileName ??
                                'Upload ${_selectedType.toUpperCase()}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedType == 'video')
                AppTextFormField(
                  controller: videoUrlController,
                  label: 'Video Url',
                  hint: 'https://youtu.be/G_H-BoEfwjo?si=qeos4qVG5iAfcLl0',
                ),

              const SizedBox(height: 20),

              /// Submit Button
              ///
              AppFilledButton(
                icon: Icon(Icons.add, color: Colors.white),
                label: 'Create Lesson',
                onTap: state is AdminCourseSubmitting ? null : _submitLesson,
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitLesson() {
    if (_titleController.text.isEmpty ||
        _sequenceController.text.isEmpty ||
        (_selectedType == 'video' && videoUrlController.text.isEmpty)) {
      return;
    }

    context.read<AdminLessonBloc>().add(
      CreateLessonEvent(
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        sequence: int.parse(_sequenceController.text),
        type: _selectedType,
        videoUrl: videoUrlController.text.trim(),
        fileBytes: _fileBytes,
        fileName: _fileName,
        questions: _selectedType == 'mcq' ? [] : null,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppText.interLarge(
        text,
        // weight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
