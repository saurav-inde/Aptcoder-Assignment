// --- Events ---
import 'dart:async';

import 'package:aptcoder/core/models/lesson.dart';
import 'package:aptcoder/core/models/progress.dart';
import 'package:aptcoder/core/services/databse_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LessonEvent {}

class LoadLessons extends LessonEvent {
  final String courseId;
  final String userId;

  LoadLessons({required this.courseId, required this.userId});
}

class LoadLessonsPurely extends LessonEvent {
  final String courseId;

  LoadLessonsPurely({required this.courseId});
}

class MarkLessonAsComplete extends LessonEvent {
  final String courseId;
  final String lessonId;
  final String userId;

  MarkLessonAsComplete({
    required this.courseId,
    required this.lessonId,
    required this.userId,
  });
}

class UpdateMcqProgress extends LessonEvent {
  final String userId;
  final String courseId;
  final String lessonId;
  final int quesSeq;
  final int chosenOption;

  UpdateMcqProgress({
    required this.userId,
    required this.courseId,
    required this.lessonId,
    required this.quesSeq,
    required this.chosenOption,
  });
}

// Internal events
class _LessonsUpdated extends LessonEvent {
  final List<LessonModel> lessons;
  _LessonsUpdated(this.lessons);
}

class _ProgressUpdated extends LessonEvent {
  final List<ProgressModel> progress;
  _ProgressUpdated(this.progress);
}

// --- States ---
abstract class LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final List<LessonModel> lessons;
  final List<String> completedLessonIds;
  final List<ProgressModel> progress;

  LessonLoaded({
    required this.lessons,
    required this.completedLessonIds,
    required this.progress,
  });
}

// --- BLoC ---
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final DatabaseService _dbService;

  StreamSubscription? _lessonSub;
  StreamSubscription? _progressSub;

  List<LessonModel> _lessons = [];
  List<ProgressModel> _progress = [];

  LessonBloc(this._dbService) : super(LessonLoading()) {
    on<LoadLessons>(_onLoadLessons);
    on<LoadLessonsPurely>(_onLoadLessonsPurely);
    on<MarkLessonAsComplete>(_onMarkLessonAsComplete);
    on<_LessonsUpdated>(_onLessonsUpdated);
    on<_ProgressUpdated>(_onProgressUpdated);
    on<UpdateMcqProgress>(_onUpdateMcqProgress);
  }

  Future<void> _onLoadLessons(
    LoadLessons event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());

    _lessonSub?.cancel();
    _progressSub?.cancel();

    // Listen to lessons
    _lessonSub = _dbService.streamLessons(event.courseId).listen((lessons) {
      add(_LessonsUpdated(lessons));
    });

    // Listen to progress (NEW MODEL)
    _progressSub = _dbService
        .streamCourseProgress(event.userId, event.courseId)
        .listen((progress) {
          add(_ProgressUpdated(progress));
        });
  }

  Future<void> _onLoadLessonsPurely(
    LoadLessonsPurely event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());

    _lessonSub?.cancel();
    _progressSub?.cancel();

    // Listen to lessons
    _lessonSub = _dbService.streamLessons(event.courseId).listen((lessons) {
      add(_LessonsUpdated(lessons));
    });
  }

  Future<void> _onMarkLessonAsComplete(
    MarkLessonAsComplete event,
    Emitter<LessonState> emit,
  ) async {
    await _dbService.markLessonCompleted(
      event.userId,
      event.courseId,
      event.lessonId,
    );
    // Stream will auto-update
  }

  Future<void> _onUpdateMcqProgress(
    UpdateMcqProgress event,
    Emitter<LessonState> emit,
  ) async {
    await _dbService.updateMcqProgress(
      userId: event.userId,
      courseId: event.courseId,
      lessonId: event.lessonId,
      quesSeq: event.quesSeq,
      chosenOption: event.chosenOption,
    );
  }

  void _onLessonsUpdated(_LessonsUpdated event, Emitter<LessonState> emit) {
    _lessons = event.lessons;
    _emitCombinedState(emit);
  }

  void _onProgressUpdated(_ProgressUpdated event, Emitter<LessonState> emit) {
    _progress = event.progress;
    _emitCombinedState(emit);
  }

  void _emitCombinedState(Emitter<LessonState> emit) {
    final completedLessonIds = _progress
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toList();

    emit(
      LessonLoaded(
        lessons: _lessons,
        completedLessonIds: completedLessonIds,
        progress: _progress,
      ),
    );
  }

  @override
  Future<void> close() {
    _lessonSub?.cancel();
    _progressSub?.cancel();
    return super.close();
  }
}
