import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:aptcoder/ui/screens/admin/lessons_screen.dart';
import 'package:aptcoder/ui/screens/enroll_course_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseEntryGate extends StatelessWidget {
  final CourseModel course;

  const CourseEntryGate({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is UserLoaded) {
          final isEnrolled = state.user.enrolledCourseIds.contains(course.id);

          return isEnrolled
              ? AdminLessonsScreen(course: course)
              : EnrollCourseScreen(course: course);
        }

        return const Scaffold(body: Center(child: Text('Failed to load user')));
      },
    );
  }
}
