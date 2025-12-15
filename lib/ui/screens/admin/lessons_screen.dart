import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/core/models/lesson.dart';
import 'package:aptcoder/core/models/progress.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:aptcoder/ui/screens/admin/add_lesson_sheet.dart';
import 'package:aptcoder/ui/screens/admin/add_mcq_lesson.dart';
import 'package:aptcoder/ui/screens/admin/lesson_video_screen.dart';
import 'package:aptcoder/ui/screens/admin/pdf_lesson_screen.dart';
import 'package:aptcoder/ui/screens/admin/ppt_lesson_screen.dart';
import 'package:aptcoder/ui/screens/admin/view_mcq_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminLessonsScreen extends StatefulWidget {
  final CourseModel course;

  const AdminLessonsScreen({super.key, required this.course});

  @override
  State<AdminLessonsScreen> createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  @override
  void initState() {
    context.read<LessonBloc>().add(
      LoadLessons(
        courseId: widget.course.id,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          // appBar: AppBar(
          //   // title: AppText.interLarge('Course Lessons', weight: FontWeight.bold),
          //   backgroundColor: Colors.white,
          //   elevation: 0,
          // ),
          floatingActionButton:
              ((userState is UserLoaded)
                  ? userState.user.role == 'admin'
                  : false)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.extended(
                      backgroundColor: primaryColor,
                      label: AppText.interLarge(
                        'Add Quiz',
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddMcqLessonScreen(courseId: widget.course.id),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    FloatingActionButton.extended(
                      backgroundColor: primaryColor,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) =>
                              AddLessonBottomSheet(courseId: widget.course.id),
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => BottomSheet(
                        //       builder: (context) => AddLessonBottomSheet(
                        //         courseId: widget.course.id,
                        //       ),
                        //       onClosing: () {},
                        //     ),
                        //   ),
                        // );
                      },
                      label: AppText.interMedium(
                        'Add Lesson',
                        color: Colors.white,
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                )
              : null,
          body: Column(
            children: [
              /// Course header
              // _CourseHeader(course: widget.course),
              // SizedBox(height: 16),
              // Padding(
              //   padding: EdgeInsetsGeometry.only(left: 16),
              //   child: Align(
              //     alignment: Alignment.topLeft,
              //     child: AppText.interLarger('Lessons', weight: FontWeight.bold),
              //   ),
              // ),

              /// Lessons list
              Expanded(
                child: BlocBuilder<LessonBloc, LessonState>(
                  builder: (context, state) {
                    if (state is LessonLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is LessonLoaded) {
                      if (state.lessons.isEmpty) {
                        return Center(
                          child: AppText.interMedium(
                            'No lessons added yet',
                            color: Colors.grey,
                          ),
                        );
                      }

                      final lessons = [...state.lessons]
                        ..sort((a, b) => a.sequence.compareTo(b.sequence));

                      return ListView.separated(
                        // padding: const EdgeInsets.all(16),
                        itemCount: lessons.length + 1,
                        separatorBuilder: (_, idx) {
                          if (idx == 0 || idx == lessons.length) {
                            return SizedBox.shrink();
                          }
                          return Container(
                            height: 8,
                            decoration: BoxDecoration(
                              border: BoxBorder.fromLTRB(
                                top: BorderSide(
                                  color: const Color.fromARGB(
                                    255,
                                    227,
                                    227,
                                    227,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CourseHeader(course: widget.course),
                                SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: AppText.interLarger('Lessons'),
                                ),
                              ],
                            );
                          }
                          final lessonProgress = state.progress
                              .where((p) => p.lessonId == lessons[index - 1].id)
                              .toList();

                          return _AdminLessonTile(
                            lesson: lessons[index - 1],
                            progress: lessonProgress.isNotEmpty
                                ? lessonProgress.first
                                : null,
                            isAdmin: ((userState is UserLoaded)
                                ? userState.user.role == 'admin'
                                : false),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final CourseModel course;

  const _CourseHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Thumbnail
          Image.network(course.thumbnail, fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                /// Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.interLargest(
                        course.title,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      AppText.interMedium(
                        course.description,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: course.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AppText.interSmall(
                                  tag,
                                  color: primaryColor,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminLessonTile extends StatelessWidget {
  final LessonModel lesson;
  final ProgressModel? progress;
  final bool isAdmin;

  const _AdminLessonTile({
    required this.lesson,
    this.progress,
    required this.isAdmin,
  });

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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _handleLessonTap(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// Icon
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(lesson.type),
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.interMedium(
                    '${lesson.sequence.toString().padLeft(2, '0')} · ${lesson.title}',
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      AppText.interSmall(
                        lesson.type.toUpperCase(),
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      if (progress?.completed == true)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      if (lesson.type == 'mcq' && progress != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: AppText.interSmall(
                            '${progress!.mcq.length} solved',
                            color: primaryColor,
                            weight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// More menu
            if (isAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleLessonTap(BuildContext context) async {
    final tracker = LessonTimeTracker();

    switch (lesson.type) {
      case 'video':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonVideoScreen(lesson: lesson)),
        );
        if (tracker.hasSpentEnoughTime(LessonCompletionRules.videoMinSeconds))
          _markCompleted(context);
        break;

      case 'pdf':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LessonPdfScreen(pdfUrl: lesson.url ?? '', title: lesson.title),
          ),
        );
        if (tracker.hasSpentEnoughTime(LessonCompletionRules.pdfMinSeconds))
          _markCompleted(context);
        break;

      case 'ppt':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LessonPptScreen(title: lesson.title, pptUrl: lesson.url!),
          ),
        );
        if (tracker.hasSpentEnoughTime(LessonCompletionRules.pptMinSeconds))
          _markCompleted(context);
        break;

      case 'mcq':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewMcqScreen(lesson: lesson)),
        );
        break;
    }
  }

  void _markCompleted(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    context.read<LessonBloc>().add(
      MarkLessonAsComplete(
        userId: userId,
        courseId: lesson.courseId,
        lessonId: lesson.id,
      ),
    );
  }
}

class LessonCompletionRules {
  static const videoMinSeconds = 30;
  static const pdfMinSeconds = 20;
  static const pptMinSeconds = 20;
}

class LessonTimeTracker {
  late final DateTime _startTime;

  LessonTimeTracker() {
    _startTime = DateTime.now();
  }

  bool hasSpentEnoughTime(int minSeconds) {
    final spent = DateTime.now().difference(_startTime).inSeconds;
    return spent >= minSeconds;
  }
}
