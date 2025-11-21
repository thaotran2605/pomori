// lib/views/day_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/pomodoro_service.dart';
import '../models/pomodoro_task.dart';
import 'timer_screen.dart';

class DayTasksScreen extends StatefulWidget {
  const DayTasksScreen({super.key});

  static const routeName = AppRoutes.dayTasks;

  @override
  State<DayTasksScreen> createState() => _DayTasksScreenState();
}

class _DayTasksScreenState extends State<DayTasksScreen> {
  final PomodoroService _pomodoroService = PomodoroService();
  late DateTime _selectedDay;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _currentWeekStart = _getWeekStart(_selectedDay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is DateTime) {
      setState(() {
        _selectedDay = DateTime(args.year, args.month, args.day);
        _currentWeekStart = _getWeekStart(_selectedDay);
      });
    }
  }

  // Hàm lấy ngày đầu tuần (Chủ nhật)
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromSunday = weekday % 7; // 0 = CN, 1 = T2, ..., 6 = T7
    return DateTime(date.year, date.month, date.day - daysFromSunday);
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
      _currentWeekStart = _getWeekStart(_selectedDay);
    });
  }

  // Hàm sinh 7 ngày trong tuần
  List<DateTime> _getDaysInWeek() {
    return List.generate(
      7,
      (index) => DateTime(
        _currentWeekStart.year,
        _currentWeekStart.month,
        _currentWeekStart.day + index,
      ),
    );
  }

  Color _getTaskColor(int index) {
    final colors = [kPrimaryRed, Colors.green, Colors.orange, Colors.blue];
    return colors[index % colors.length];
  }

  void _startPomodoro(PomodoroTask task) {
    Navigator.of(context).pushNamed(TimerScreen.routeName, arguments: task);
  }

  void _onTabSelected(BuildContext context, int index) {
    BottomNavNavigator.goTo(context, index);
  }

  String _formatSelectedDate(DateTime date) {
    final weekdays = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy'
    ];
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final weekDays = _getDaysInWeek();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/pomori_logo2.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'Tasks',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: kPrimaryRed,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.newTask);
            },
          ),
        ],
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

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Lỗi khi tải dữ liệu: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextColor.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final allTasks = snapshot.data ?? [];

            // Lọc tasks theo ngày đã chọn
            final selectedDayTasks = allTasks.where((task) {
              final taskDate = DateTime(
                task.date.year,
                task.date.month,
                task.date.day,
              );
              final selectedDate = DateTime(
                _selectedDay.year,
                _selectedDay.month,
                _selectedDay.day,
              );
              return taskDate.year == selectedDate.year &&
                  taskDate.month == selectedDate.month &&
                  taskDate.day == selectedDate.day;
            }).toList();

            // Sort tasks by start time
            selectedDayTasks.sort((a, b) {
              final aTime = DateTime(
                _selectedDay.year,
                _selectedDay.month,
                _selectedDay.day,
                a.startTime.hour,
                a.startTime.minute,
              );
              final bTime = DateTime(
                _selectedDay.year,
                _selectedDay.month,
                _selectedDay.day,
                b.startTime.hour,
                b.startTime.minute,
              );
              return aTime.compareTo(bTime);
            });

            return Column(
              children: [
                // Week Navigation
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: kTextColor),
                        onPressed: _previousWeek,
                      ),
                      Text(
                        _formatSelectedDate(_selectedDay),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: kTextColor,
                        ),
                        onPressed: _nextWeek,
                      ),
                    ],
                  ),
                ),
                // Week Day Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDays.map((day) {
                      final dayOnly = DateTime(day.year, day.month, day.day);
                      final selectedDateOnly = DateTime(
                        _selectedDay.year,
                        _selectedDay.month,
                        _selectedDay.day,
                      );
                      final isSelected =
                          dayOnly.isAtSameMomentAs(selectedDateOnly);
                      final dayName = DateFormat('E').format(day);
                      final dayNumber = day.day;
                      final isToday = dayOnly.isAtSameMomentAs(today);

                      // Đếm số tasks cho ngày này
                      final dayTasks = allTasks.where((task) {
                        final taskDate = DateTime(
                          task.date.year,
                          task.date.month,
                          task.date.day,
                        );
                        return taskDate.year == day.year &&
                            taskDate.month == day.month &&
                            taskDate.day == day.day;
                      }).length;

                      return GestureDetector(
                        onTap: () => _selectDay(day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimaryRed
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: isToday && !isSelected
                                ? Border.all(color: kPrimaryRed, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : kTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : kTextColor,
                                ),
                              ),
                              if (dayTasks > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : kPrimaryRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Tasks List
                Expanded(
                  child: selectedDayTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 60,
                                color: kTextColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'No tasks for this day',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: kTextColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: selectedDayTasks.length,
                          itemBuilder: (context, index) {
                            final task = selectedDayTasks[index];
                            final taskColor = _getTaskColor(index);

                            // Tính thời gian bắt đầu
                            final startDateTime = DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                              task.startTime.hour,
                              task.startTime.minute,
                            );
                            final startTime =
                                DateFormat('hh:mm a').format(startDateTime);

                            // Tính thời gian kết thúc
                            final totalMinutes = (task.sessions * task.focusTime) +
                                ((task.sessions - 1) * task.breakTime);
                            final endDateTime =
                                startDateTime.add(Duration(minutes: totalMinutes));
                            final endTimeStr =
                                DateFormat('hh:mm a').format(endDateTime);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time label
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      startTime,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: kTextColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Task card
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _startPomodoro(task),
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: taskColor,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: taskColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '$startTime - $endTimeStr',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onTabSelected(context, index),
      ),
    );
  }
}

