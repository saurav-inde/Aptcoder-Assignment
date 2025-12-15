// --- Events ---
import 'dart:typed_data';

import 'package:aptcoder/core/services/databse_service.dart';
import 'package:aptcoder/core/services/supabase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AdminCourseEvent {}

class CreateCourseEvent extends AdminCourseEvent {
  final String title;
  final String description;
  final Uint8List thumbnailBytes;
  final List<String> tags;

  CreateCourseEvent({
    required this.title,
    required this.description,
    required this.thumbnailBytes,
    required this.tags,
  });
}

// --- States ---
abstract class AdminCourseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminCourseInitial extends AdminCourseState {}

class AdminCourseSubmitting extends AdminCourseState {}

class AdminCourseSuccess extends AdminCourseState {}

class AdminCourseFailure extends AdminCourseState {
  final String error;
  AdminCourseFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// --- BLoC ---
class AdminCourseBloc extends Bloc<AdminCourseEvent, AdminCourseState> {
  final DatabaseService _dbService;
  final FileStorageService _storageService;

  AdminCourseBloc(this._dbService, this._storageService)
    : super(AdminCourseInitial()) {
    on<CreateCourseEvent>(_onCreateCourse);
  }

  Future<void> _onCreateCourse(
    CreateCourseEvent event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseSubmitting());
    try {
      // 1. Upload Thumbnail
      final String filePath =
          'courses/${DateTime.now().millisecondsSinceEpoch}_thumb';
      final String? downloadUrl = await _storageService.uploadFile(
        filePath: filePath,
        fileBytes: event.thumbnailBytes,
      );

      if (downloadUrl == null) throw Exception('Failed to upload thumbnail');

      // 2. Create Course Data
      final courseMap = {
        'title': event.title,
        'description': event.description,
        'thumbnail': downloadUrl,
        'tags': event.tags,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. Save to Firestore
      await _dbService.addCourse(courseMap);

      emit(AdminCourseSuccess());
    } catch (e) {
      emit(AdminCourseFailure(e.toString()));
    }
  }
}
