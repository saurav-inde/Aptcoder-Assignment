
import 'dart:developer';
import 'dart:typed_data';

import 'package:aptcoder/core/services/databse_service.dart';
import 'package:aptcoder/core/services/supabase_storage.dart';
import 'package:aptcoder/state/admin_course_mgt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CreateLessonEvent extends AdminCourseEvent {
  final String courseId;
  final String title;
  final int sequence;
  final String type; 
  final Uint8List? fileBytes; 
  final String? videoUrl;
  final String? fileName;
  final List<Map<String, dynamic>>? questions; 

  CreateLessonEvent({
    required this.courseId,
    required this.title,
    required this.sequence,
    required this.type,
    this.videoUrl,
    this.fileBytes,
    this.fileName,
    this.questions,
  });
}


class AdminLessonBloc extends Bloc<CreateLessonEvent, AdminCourseState> {
  final DatabaseService _dbService;
  final FileStorageService _storageService;

  AdminLessonBloc(this._dbService, this._storageService)
    : super(AdminCourseInitial()) {
    on<CreateLessonEvent>(_onCreateLesson);
  }

  Future<void> _onCreateLesson(
    CreateLessonEvent event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseSubmitting());
    try {
      String? resourceUrl = event.videoUrl;

      
      if (event.fileBytes != null && event.fileName != null) {
        final path =
            'courses/${event.courseId}/lessons/${DateTime.now().millisecondsSinceEpoch}_${event.fileName}';
        resourceUrl = await _storageService.uploadFile(
          filePath: path,
          fileBytes: event.fileBytes!,
        );
        if (resourceUrl == null) throw Exception("File upload failed");
        log(resourceUrl);
      }

      
      final lessonMap = {
        'title': event.title,
        'sequence': event.sequence,
        'type': event.type,
        'url': resourceUrl,
        'questions': event.questions,
      };

      
      await _dbService.addLesson(event.courseId, lessonMap);

      emit(AdminCourseSuccess());
    } catch (e) {
      emit(AdminCourseFailure(e.toString()));
    }
  }
}
