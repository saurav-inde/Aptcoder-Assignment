// --- Events ---
import 'dart:async';

import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/core/services/databse_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CourseListEvent {}

class LoadCourses extends CourseListEvent {}

class _CoursesUpdated extends CourseListEvent {
  final List<CourseModel> courses;
  _CoursesUpdated(this.courses);
}

class SearchCourses extends CourseListEvent {
  final String query;
  SearchCourses(this.query);
}

// --- States ---
abstract class CourseListState {}

class CourseListLoading extends CourseListState {}

class CourseListLoaded extends CourseListState {
  final List<CourseModel> courses;
  CourseListLoaded(this.courses);
}

class CourseListError extends CourseListState {
  final String message;
  CourseListError(this.message);
}

// --- BLoC ---
class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  final DatabaseService _dbService;
  StreamSubscription? _courseSubscription;
  List<CourseModel> _allCourses = [];

  CourseListBloc(this._dbService) : super(CourseListLoading()) {
    on<LoadCourses>((event, emit) {
      _courseSubscription?.cancel();
      _courseSubscription = _dbService.streamCourses().listen((courses) {
        _allCourses = courses;
        add(_CoursesUpdated(courses));
      }, onError: (error) => emit(CourseListError(error.toString())));
    });

    on<_CoursesUpdated>((event, emit) {
      emit(CourseListLoaded(event.courses));
    });
    on<SearchCourses>((event, emit) {
      final query = event.query.trim().toLowerCase();

      if (query.isEmpty) {
        emit(CourseListLoaded(_allCourses));
        return;
      }

      final filtered = _allCourses.where((course) {
        final titleMatch = course.title.toLowerCase().contains(query);
        final descMatch = course.description.toLowerCase().contains(query);
        final tagMatch = course.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );

        return titleMatch || descMatch || tagMatch;
      }).toList();

      emit(CourseListLoaded(filtered));
    });
  }

  @override
  Future<void> close() {
    _courseSubscription?.cancel();
    return super.close();
  }
}
