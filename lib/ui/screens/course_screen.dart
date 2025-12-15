import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/user.dart';
import 'package:aptcoder/state/course_list_bloc.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:aptcoder/ui/screens/admin/create_course_screen.dart';
import 'package:aptcoder/ui/screens/admin/lessons_screen.dart';
import 'package:aptcoder/ui/screens/admin/student_profile.dart';
import 'package:aptcoder/ui/screens/course_gate.dart';
import 'package:aptcoder/ui/screens/student_dashboard.dart';
import 'package:aptcoder/ui/widgets/course_card.dart';
import 'package:aptcoder/ui/widgets/navbar.dart';
import 'package:aptcoder/ui/widgets/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentHomeShell extends StatefulWidget {
  const StudentHomeShell({super.key});

  @override
  State<StudentHomeShell> createState() => _StudentHomeShellState();
}

class _StudentHomeShellState extends State<StudentHomeShell> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBottomNav = true;

  @override
  void initState() {
    super.initState();

    context.read<UserBloc>().add(
      LoadUser(FirebaseAuth.instance.currentUser!.uid),
    );

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse && _showBottomNav) {
        setState(() => _showBottomNav = false);
      } else if (direction == ScrollDirection.forward && !_showBottomNav) {
        setState(() => _showBottomNav = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final isAdmin = ((userState is UserLoaded)
            ? userState.user.role == 'admin'
            : false);
        return Scaffold(
          backgroundColor: backgroundColor,

          /// 🔝 SAME APP BAR FOR ALL TABS
          appBar: _buildAppBar(context),
          floatingActionButton: isAdmin
              ? FloatingActionButton.extended(
                  backgroundColor: primaryColor,
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCourseScreen(),
                      ),
                    );
                  },
                  label: AppText.interLarge('New Course', color: Colors.white),
                )
              : null,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: [
                  CourseListBody(
                    scrollController: _scrollController,
                    isAdmin: isAdmin,
                  ),
                  StudentDashboardBody(scrollController: _scrollController),
                ],
              ),
              if (!isAdmin)
                AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  offset: _showBottomNav ? Offset.zero : const Offset(0, 1.2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showBottomNav ? 1 : 0,
                    child: BottomDockNav(
                      selectedIndex: _currentIndex,
                      onTap: (index) {
                        setState(() => _currentIndex = index);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final user = userState is UserLoaded
        ? userState.user
        : UserModel(
            uid: 'uid',
            email: 'newuser@aptcoder',
            displayName: 'Welcome',
            role: 'student',
            createdAt: DateTime.now(),
          );

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leadingWidth: 70,
      shadowColor: const Color.fromARGB(255, 237, 237, 237),
      actionsPadding: const EdgeInsets.only(right: 12),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.interLarger(user.displayName, weight: FontWeight.bold),
          AppText.urbanMedium(
            user.email,
            color: Colors.grey,
            weight: FontWeight.bold,
          ),
        ],
      ),
      leading: Row(
        children: [
          const SizedBox(width: 12),
          IconButton(
            icon: CircleAvatar(
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentProfileScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const CircleAvatar(
            backgroundColor: Color.fromARGB(255, 243, 243, 243),
            child: Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    );
  }
}

class CourseListBody extends StatefulWidget {
  const CourseListBody({
    super.key,
    required this.scrollController,
    required this.isAdmin,
  });
  final ScrollController scrollController;
  final bool isAdmin;
  @override
  State<CourseListBody> createState() => _CourseListBodyState();
}

class _CourseListBodyState extends State<CourseListBody> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseListBloc, CourseListState>(
      builder: (context, state) {
        if (state is CourseListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CourseListError) {
          return Center(
            child: AppText.interMedium(state.message, color: Colors.red),
          );
        }

        if (state is CourseListLoaded) {
          return ListView.separated(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.courses.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return AppSearchBar(
                  onChanged: (query) {
                    context.read<CourseListBloc>().add(SearchCourses(query));
                  },
                  controller: searchController,
                );
              }

              final course = state.courses[index - 1];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => widget.isAdmin
                          ? AdminLessonsScreen(course: course)
                          : CourseEntryGate(course: course),
                    ),
                  );
                },
                child: CourseCard(course: course),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class StudentDashboardBody extends StatelessWidget {
  const StudentDashboardBody({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StudentDashboardScreen(
      scrollController: scrollController,
    ); // or extract body if needed
  }
}
