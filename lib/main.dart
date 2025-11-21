// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'utils/app_constants.dart';
import 'utils/app_routes.dart';
import 'views/congrats_screen.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/new_pomori_screen.dart';
import 'views/new_task_screen.dart';
import 'views/profile_screen.dart';
import 'views/signup_screen.dart';
import 'views/stats_screen.dart';
import 'views/timer_screen.dart';
import 'views/tasks_screen.dart';
import 'views/day_tasks_screen.dart';

void main() async {
  // Lệnh này quan trọng để đảm bảo Flutter khởi tạo đúng cách
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomori App',
      theme: ThemeData(
        // Thiết lập Theme cơ bản
        primarySwatch: Colors.red,
        scaffoldBackgroundColor:
            kLightBackgroundColor, // Đặt màu nền mặc định cho Scaffold
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryRed,
          primary: kPrimaryRed,
        ),
        useMaterial3: true,
      ),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.tasks: (context) => const TasksScreen(),
        AppRoutes.dayTasks: (context) => const DayTasksScreen(),
        AppRoutes.newPomori: (context) => const NewPomoriScreen(),
        AppRoutes.newTask: (context) => const NewTaskScreen(),
        AppRoutes.stats: (context) => const StatsScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.timer: (context) => const TimerScreen(),
        AppRoutes.congrats: (context) => const CongratsScreen(),
      },
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
