import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/core/models/lesson.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnrollCourseScreen extends StatelessWidget {
  final CourseModel course;

  const EnrollCourseScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: _EnrollBottomBar(course: course),
      body: CustomScrollView(
        slivers: [
          _CourseHero(course: course),
          SliverToBoxAdapter(child: _CourseMeta(course: course)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: AppText.interLarger('Lessons', weight: FontWeight.bold),
            ),
          ),
          _LockedLessonsList(courseId: course.id),
        ],
      ),
    );
  }
}

class _CourseHero extends StatelessWidget {
  final CourseModel course;
  const _CourseHero({required this.course});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        title: AppText.interMedium(course.title),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(course.thumbnail, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseMeta extends StatelessWidget {
  final CourseModel course;
  const _CourseMeta({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.interMedium(course.description, color: Colors.grey.shade700),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: course.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText.interSmall(tag, color: primaryColor),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LockedLessonsList extends StatefulWidget {
  final String courseId;
  const _LockedLessonsList({required this.courseId});

  @override
  State<_LockedLessonsList> createState() => _LockedLessonsListState();
}

class _LockedLessonsListState extends State<_LockedLessonsList> {
  @override
  void initState() {
    context.read<LessonBloc>().add(
      LoadLessonsPurely(courseId: widget.courseId),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is LessonLoaded) {
            final lessons = [...state.lessons]
              ..sort((a, b) => a.sequence.compareTo(b.sequence));

            return Column(
              children: lessons.map((lesson) {
                return _LockedLessonTile(lesson: lesson);
              }).toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LockedLessonTile extends StatelessWidget {
  final LessonModel lesson;
  const _LockedLessonTile({required this.lesson});

  IconData _iconForType(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'mcq':
        return Icons.quiz_outlined;
      case 'ppt':
        return Icons.slideshow_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.85,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForType(lesson.type), color: Colors.grey),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.interMedium(
                    '${lesson.sequence.toString().padLeft(2, '0')} · ${lesson.title}',
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 6),
                  AppText.interSmall(
                    'Enroll to unlock',
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            const Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _EnrollBottomBar extends StatelessWidget {
  final CourseModel course;
  const _EnrollBottomBar({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            context.read<UserBloc>().add(
              EnrollInCourse(
                uid: FirebaseAuth.instance.currentUser!.uid,
                courseId: course.id,
              ),
            );
          },
          child: AppText.interLarge(
            'Enroll & Unlock All Lessons',
            color: Colors.white,
            weight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
