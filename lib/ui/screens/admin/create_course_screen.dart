

import 'dart:typed_data';
import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/appoutlinedbutton.dart';
import 'package:aptcoder/core/app_widgets/apptextformfield.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aptcoder/state/admin_course_mgt.dart';

import 'package:file_picker/file_picker.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController tagsCtrl = TextEditingController();

  
  Uint8List? pickedImageBytes;
  String? pickedImageName;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
        withData: true, 
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          pickedImageBytes = result.files.single.bytes;
          pickedImageName = result.files.single.name;
        });
      }
    } catch (e) {
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _submitCourse() {
    if (_formKey.currentState!.validate()) {
      if (pickedImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a course thumbnail.')),
        );
        return;
      }

      
      final tagsList = tagsCtrl.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      
      context.read<AdminCourseBloc>().add(
        CreateCourseEvent(
          title: titleCtrl.text,
          description: descCtrl.text,
          thumbnailBytes: pickedImageBytes!,
          tags: tagsList,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Create New Course'),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
      ),
      body: BlocListener<AdminCourseBloc, AdminCourseState>(
        listener: (context, state) {
          if (state is AdminCourseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Course Created Successfully!")),
            );
            Navigator.of(context).pop();
          }
          if (state is AdminCourseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to create course: ${state.error}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                AppTextFormField(
                  controller: titleCtrl,
                  hint: 'Flutter for Beginners',
                  label: 'Course Title',
                  validator: (value) =>
                      value!.isEmpty ? 'Title cannot be empty' : null,
                ),

                const SizedBox(height: 16),

                
                AppTextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  hint: 'Describe your course breifly',
                  label: 'Description',
                  validator: (value) =>
                      value!.isEmpty ? 'Description cannot be empty' : null,
                ),

                const SizedBox(height: 16),

                
                AppTextFormField(
                  controller: tagsCtrl,
                  label: 'Tags',
                  hint: 'flutter, mobile, dart',
                ),
                const SizedBox(height: 24),

                
                AppText.interLarge(
                  'Course Thumbnail:',
                  
                ),
                const SizedBox(height: 8),
                AppOutlinedButton(
                  onTap: _pickImage,
                  label: pickedImageName ?? 'Select Thumbnail Image',
                  icon: Icon(
                    Icons.photo_size_select_actual_rounded,
                    color: primaryColor,
                  ),
                ),

                if (pickedImageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image.memory(
                      pickedImageBytes!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 32),

                
                BlocBuilder<AdminCourseBloc, AdminCourseState>(
                  builder: (context, state) {
                    final bool isLoading = state is AdminCourseSubmitting;
                    return AppFilledButton(
                      icon: isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload, color: Colors.white),
                      label: isLoading ? "Creating Course..." : "Create Course",
                      onTap: isLoading ? null : _submitCourse,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
