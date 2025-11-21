// lib/views/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/pomodoro_log_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  static const routeName = AppRoutes.stats;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final PomodoroLogService _logService = PomodoroLogService();
  Map<String, dynamic>? _totalStats;
  int _streak = 0;
  List<Map<String, dynamic>>? _weeklyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final totalStats = await _logService.getTotalStats(user.uid);
      final streak = await _logService.getStreak(user.uid);
      final weeklyData = await _logService.getWeeklyChartData(user.uid);

      if (mounted) {
        setState(() {
          _totalStats = totalStats;
          _streak = streak;
          _weeklyData = weeklyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải thống kê: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatFocusTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  void _onTabSelected(BuildContext context, int index) {
    BottomNavNavigator.goTo(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimaryRed),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStats();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Focus',
                            value: _formatFocusTime(
                                _totalStats?['totalFocusTime'] ?? 0),
                            icon: Icons.timer,
                            color: kPrimaryRed,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Sessions',
                            value: '${_totalStats?['totalSessions'] ?? 0}',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Tasks Done',
                            value: '${_totalStats?['tasksDone'] ?? 0}',
                            icon: Icons.task_alt,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Streak',
                            value: '$_streak ${_streak == 1 ? 'day' : 'days'}',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Chart section
                    Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_weeklyData != null && _weeklyData!.isNotEmpty)
                            ..._weeklyData!.map((dayData) {
                              final sessions = dayData['sessions'] as int;
                              // Tính giá trị progress (giả sử mục tiêu là 8 sessions/ngày)
                              const maxSessions = 8;
                              final progress = sessions > maxSessions
                                  ? 1.0
                                  : sessions / maxSessions;
                              return _BarChartItem(
                                day: dayData['day'] as String,
                                value: progress,
                                sessions: sessions,
                              );
                            }).toList()
                          else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No data available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) => _onTabSelected(context, index),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: kTextColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class _BarChartItem extends StatelessWidget {
  final String day;
  final double value;
  final int sessions;

  const _BarChartItem({
    required this.day,
    required this.value,
    this.sessions = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                color: kTextColor.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: kPrimaryRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$sessions sessions',
            style: TextStyle(fontSize: 12, color: kTextColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
