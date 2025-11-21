// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/pomodoro_service.dart';
import '../models/pomodoro_task.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = AppRoutes.home;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PomodoroService _pomodoroService = PomodoroService();
  final int _dailyGoal = 8; // Mục tiêu số session mỗi ngày

  void _onTabSelected(BuildContext context, int index) {
    BottomNavNavigator.goTo(context, index);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  void _startPomodoro(PomodoroTask task) {
    Navigator.of(context).pushNamed(TimerScreen.routeName, arguments: task);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/pomori_logo2.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Pomori',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PomodoroTask>>(
          stream: user != null
              ? _pomodoroService.getPomodoroTasks(user.uid)
              : Stream.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allTasks = snapshot.data ?? [];
            final today = DateTime.now();
            final todayTasks = allTasks.where((task) {
              final taskDate = DateTime(
                task.date.year,
                task.date.month,
                task.date.day,
              );
              final todayDate = DateTime(today.year, today.month, today.day);
              return taskDate.isAtSameMomentAs(todayDate) && !task.isCompleted;
            }).toList();

            // Tính progress cho mục tiêu ngày
            final completedSessionsToday = allTasks
                .where((task) {
                  final taskDate = DateTime(
                    task.date.year,
                    task.date.month,
                    task.date.day,
                  );
                  final todayDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  return taskDate.isAtSameMomentAs(todayDate);
                })
                .fold<int>(0, (sum, task) {
                  // Nếu task đã hoàn thành, tính tất cả sessions
                  // Nếu chưa hoàn thành, tính currentSession (session đang làm hoặc đã làm)
                  if (task.isCompleted) {
                    return sum + task.sessions;
                  } else {
                    return sum + task.currentSession;
                  }
                });
            final progress = (_dailyGoal > 0)
                ? (completedSessionsToday / _dailyGoal).clamp(0.0, 1.0)
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    '$greeting, $userName 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Daily Goal Progress
                  _DailyGoalCard(
                    progress: progress,
                    completed: completedSessionsToday,
                    goal: _dailyGoal,
                  ),
                  const SizedBox(height: 30),
                  // Today Tasks
                  Text(
                    'Today Tasks (${todayTasks.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (todayTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 60,
                              color: kTextColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'No tasks for today',
                              style: TextStyle(
                                fontSize: 16,
                                color: kTextColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...todayTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _TodayTaskCard(
                          task: task,
                          onPlay: () => _startPomodoro(task),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => _onTabSelected(context, index),
      ),
    );
  }
}

// Daily Goal Progress Card
class _DailyGoalCard extends StatelessWidget {
  final double progress;
  final int completed;
  final int goal;

  const _DailyGoalCard({
    required this.progress,
    required this.completed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    final isAlmostDone = progress >= 0.75;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAlmostDone ? Colors.green : kPrimaryRed,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Progress Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAlmostDone
                      ? 'Wow! Your daily goals is almost done!'
                      : 'Keep going! You\'re doing great!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed/$goal sessions completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Today Task Card with Play Button
class _TodayTaskCard extends StatelessWidget {
  final PomodoroTask task;
  final VoidCallback onPlay;

  const _TodayTaskCard({required this.task, required this.onPlay});

  String _getTaskIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('read') || lowerTitle.contains('book')) {
      return '📖';
    } else if (lowerTitle.contains('audio') || lowerTitle.contains('music')) {
      return '🎵';
    } else if (lowerTitle.contains('photo') || lowerTitle.contains('image')) {
      return '📷';
    } else if (lowerTitle.contains('code') || lowerTitle.contains('program')) {
      return '💻';
    } else if (lowerTitle.contains('study') || lowerTitle.contains('learn')) {
      return '📚';
    }
    return '📝';
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = task.sessions * task.focusTime;
    final icon = _getTaskIcon(task.title);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Task Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kPrimaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 15),
          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$totalMinutes minutes',
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Play Button
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
