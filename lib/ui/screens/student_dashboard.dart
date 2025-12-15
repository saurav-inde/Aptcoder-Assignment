import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/state/course_list_bloc.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:aptcoder/ui/screens/course_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key, required this.scrollController});
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      
      
      
      
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userState is! UserLoaded) {
            return const Center(child: Text('Failed to load user'));
          }

          final enrolledIds = userState.user.enrolledCourseIds;

          if (enrolledIds.isEmpty) {
            return Center(
              child: AppText.interMedium(
                'You have not enrolled in any course yet',
                color: Colors.grey,
              ),
            );
          }

          return BlocBuilder<CourseListBloc, CourseListState>(
            builder: (context, courseState) {
              if (courseState is! CourseListLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final enrolledCourses = courseState.courses
                  .where((c) => enrolledIds.contains(c.id))
                  .toList();

              return ListView.separated(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 100,
                ),
                itemCount: enrolledCourses.length,
                separatorBuilder: (_, inde) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return DashboardCourseCard(course: enrolledCourses[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DashboardCourseCard extends StatelessWidget {
  final CourseModel course;

  const DashboardCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonBloc(context.read())
        ..add(
          LoadLessons(
            courseId: course.id,
            userId: FirebaseAuth.instance.currentUser!.uid,
          ),
        ),
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          int totalLessons = 0;
          int completedLessons = 0;

          if (state is LessonLoaded) {
            totalLessons = state.lessons.length;
            completedLessons = state.completedLessonIds.length;
          }

          final progress = totalLessons == 0
              ? 0.0
              : completedLessons / totalLessons;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseEntryGate(course: course),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(course.thumbnail, fit: BoxFit.cover),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        AppText.interLarge(
                          course.title,
                          weight: FontWeight.w800,
                        ),

                        const SizedBox(height: 6),

                        
                        AppText.interSmall(
                          course.description,
                          color: Colors.grey.shade700,
                          
                        ),

                        const SizedBox(height: 16),

                        
                        Row(
                          children: [
                            _StatPill(
                              label: 'Lessons',
                              value: totalLessons.toString(),
                              icon: Icons.menu_book_outlined,
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              label: 'Completed',
                              value: completedLessons.toString(),
                              icon: Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              label: 'Progress',
                              value: '${(progress * 100).toInt()}%',
                              icon: Icons.trending_up,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: primaryColor),
            const SizedBox(height: 6),
            AppText.interMedium(value, weight: FontWeight.bold),
            AppText.interSmall(label, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}
