import 'package:aptcoder/core/services/authentication.dart';
import 'package:aptcoder/core/services/databse_service.dart';
import 'package:aptcoder/core/services/supabase_storage.dart';
import 'package:aptcoder/state/admin_course_mgt.dart';
import 'package:aptcoder/state/admin_lesson_mgt.dart';
import 'package:aptcoder/state/course_list_bloc.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:aptcoder/state/user_bloc.dart';
import 'package:aptcoder/ui/screens/admin/create_course_screen.dart';
import 'package:aptcoder/ui/screens/course_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aptcoder/ui/screens/onboarding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://xbnbffehwdqlizqebpjk.supabase.co',
    anonKey: 'sb_publishable_1QlQJ6ALqfuAzgJPtnZCKA_kOKUINke',
  );
  AuthService().initializeGoogleSignIn(
    serverClientId:
        "1003310142314-stjlgldm4u91ijtjhr93krfuv3o5akhf.apps.googleusercontent.com",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => DatabaseService()),
        RepositoryProvider(create: (_) => FileStorageService('buck')),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CourseListBloc(context.read<DatabaseService>())
                  ..add(LoadCourses()),
          ),
          BlocProvider(
            create: (context) => AdminCourseBloc(
              context.read<DatabaseService>(),
              context.read<FileStorageService>(),
            ),
          ),

          BlocProvider(
            create: (context) => AdminLessonBloc(
              context.read<DatabaseService>(),
              context.read<FileStorageService>(),
            ),
          ),

          BlocProvider(
            create: (context) => LessonBloc(context.read<DatabaseService>()),
          ),
          BlocProvider(
            create: (context) => UserBloc(context.read<DatabaseService>()),
          ),
        ],

        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),

          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in  Go to Home
        if (snapshot.hasData) {
          return const StudentHomeShell();
        }

        return const OnboardingScreen();
      },
    );
  }
}
