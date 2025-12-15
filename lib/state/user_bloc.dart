import 'package:aptcoder/core/models/user.dart';
import 'package:aptcoder/core/services/databse_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserEvent {}

class LoadUser extends UserEvent {
  final String uid;
  LoadUser(this.uid);
}

class UpdateUserProfile extends UserEvent {
  final String uid;
  final String? educationLevel;
  final String? fieldOfStudy;
  final String? learningGoal;
  final String? photoUrl;

  UpdateUserProfile({
    required this.uid,
    this.educationLevel,
    this.fieldOfStudy,
    this.learningGoal,
    this.photoUrl,
  });
}

class EnrollInCourse extends UserEvent {
  final String uid;
  final String courseId;

  EnrollInCourse({required this.uid, required this.courseId});
}

abstract class UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final DatabaseService _dbService;

  UserBloc(this._dbService) : super(UserLoading()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<EnrollInCourse>(_onEnrollInCourse);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());

    try {
      final user = await _dbService.getUser(event.uid);

      if (user == null) {
        emit(UserError('User not found'));
        return;
      }

      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('Failed to load user'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;

    final currentUser = (state as UserLoaded).user;

    try {
      await _dbService.updateUserProfile(
        event.uid,
        educationLevel: event.educationLevel,
        fieldOfStudy: event.fieldOfStudy,
        learningGoal: event.learningGoal,
        photoUrl: event.photoUrl,
      );

      // Reload user after update
      final updatedUser = await _dbService.getUser(event.uid);
      if (updatedUser != null) {
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError('Failed to update profile'));
    }
  }

  Future<void> _onEnrollInCourse(
    EnrollInCourse event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;

    try {
      await _dbService.enrollUserInCourse(
        uid: event.uid,
        courseId: event.courseId,
      );

      // reload user
      final updatedUser = await _dbService.getUser(event.uid);
      if (updatedUser != null) {
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError('Failed to enroll in course'));
    }
  }
}
