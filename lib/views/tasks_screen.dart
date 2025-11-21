// lib/views/tasks_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../utils/navigation_utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/pomodoro_service.dart';
import '../models/pomodoro_task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  static const routeName = AppRoutes.tasks;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final PomodoroService _pomodoroService = PomodoroService();
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Timer? _dateCheckTimer;
  DateTime? _lastCheckedDate; // Lưu ngày đã check lần cuối

  void _onTabSelected(BuildContext context, int index) {
    BottomNavNavigator.goTo(context, index);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDay(DateTime day) {
    // Navigate đến màn hình tasks của ngày được chọn
    Navigator.of(context).pushNamed(
      AppRoutes.dayTasks,
      arguments: DateTime(day.year, day.month, day.day),
    );
  }

  // Lấy danh sách các ngày trong tháng để hiển thị trên calendar
  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    
    // Lấy ngày đầu tuần của tháng (Chủ nhật = 0, Thứ 2 = 1, ..., Thứ 7 = 6)
    final firstWeekday = firstDayOfMonth.weekday % 7; // Chuyển từ 1-7 sang 0-6 (CN=0, T2=1, ...)
    
    // Tạo danh sách ngày, bắt đầu từ Chủ nhật của tuần đầu tiên
    final days = <DateTime>[];
    
    // Thêm các ngày của tuần trước (nếu có)
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    
    // Tạo 42 ngày (6 tuần) để đảm bảo đủ hiển thị
    for (int i = 0; i < 42; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    
    return days;
  }

  String _formatMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // Tự động chọn ngày hôm nay
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month);
    _lastCheckedDate = DateTime(now.year, now.month, now.day);
    
    // Kiểm tra khi qua ngày mới mỗi phút
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkNewDay();
    });
  }

  // Kiểm tra khi qua ngày mới - chỉ tự động chuyển nếu đang chọn ngày quá khứ (so với ngày mới)
  void _checkNewDay() {
    if (!mounted) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Nếu đã qua ngày mới (so với lần check trước)
    if (_lastCheckedDate != null && _lastCheckedDate!.isBefore(today)) {
      final selectedDateOnly = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      
      // CHỈ tự động chuyển về ngày hôm nay nếu đang chọn ngày quá khứ (so với ngày mới)
      // Nếu người dùng đang chọn ngày hôm nay hoặc tương lai thì giữ nguyên
      if (selectedDateOnly.isBefore(today)) {
        setState(() {
          _selectedDay = today;
          _currentMonth = DateTime(today.year, today.month);
        });
      }
      
      _lastCheckedDate = today;
    } else if (_lastCheckedDate == null || !_lastCheckedDate!.isAtSameMomentAs(today)) {
      _lastCheckedDate = today;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kiểm tra khi màn hình được mở lại
    _checkNewDay();
  }

  @override
  void dispose() {
    _dateCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra khi qua ngày mới (chỉ check, không reset nếu người dùng đã chọn ngày)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNewDay();
    });
    
    final user = FirebaseAuth.instance.currentUser;
    final monthYear = _formatMonthYear(_currentMonth);

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/pomori_logo2.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Task',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
              ],
            ),
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
            final calendarDays = _getDaysInMonth();
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            
            // Đếm số tasks cho mỗi ngày để hiển thị indicator
            final Map<String, int> tasksCountByDate = {};
            for (var task in allTasks) {
              final taskDate = DateTime(
                task.date.year,
                task.date.month,
                task.date.day,
              );
              final dateKey = '${taskDate.year}-${taskDate.month}-${taskDate.day}';
              tasksCountByDate[dateKey] = (tasksCountByDate[dateKey] ?? 0) + 1;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Month Navigation
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
                          onPressed: _previousMonth,
                        ),
                        Text(
                          monthYear,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: kTextColor,
                          ),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ),
                  // Calendar Grid
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(15),
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
                      children: [
                        // Weekday headers
                        Row(
                          children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                              .map((dayName) => Expanded(
                                    child: Center(
                                      child: Text(
                                        dayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: kTextColor.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        // Calendar days grid
                        ...List.generate(6, (weekIndex) {
                          final weekDays = calendarDays.sublist(
                            weekIndex * 7,
                            (weekIndex * 7 + 7).clamp(0, calendarDays.length),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: List.generate(7, (dayIndex) {
                                if (dayIndex >= weekDays.length) {
                                  return const Expanded(child: SizedBox());
                                }
                                final day = weekDays[dayIndex];
                                final dayOnly = DateTime(day.year, day.month, day.day);
                                final selectedDateOnly = DateTime(
                                  _selectedDay.year,
                                  _selectedDay.month,
                                  _selectedDay.day,
                                );
                                final isSelected =
                                    dayOnly.isAtSameMomentAs(selectedDateOnly);
                                final isToday = dayOnly.isAtSameMomentAs(today);
                                final isCurrentMonth =
                                    day.month == _currentMonth.month &&
                                    day.year == _currentMonth.year;
                                
                                final dateKey =
                                    '${day.year}-${day.month}-${day.day}';
                                final hasTasks = tasksCountByDate[dateKey] != null &&
                                    tasksCountByDate[dateKey]! > 0;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDay(day),
                                    child: Container(
                                      height: 45,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? kPrimaryRed
                                            : (isToday && !isSelected
                                                ? kPrimaryRed.withOpacity(0.1)
                                                : Colors.transparent),
                                        shape: BoxShape.circle,
                                        border: isToday && !isSelected
                                            ? Border.all(
                                                color: kPrimaryRed,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${day.day}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isSelected || isToday
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isCurrentMonth
                                                          ? kTextColor
                                                          : kTextColor.withOpacity(0.3)),
                                                ),
                                              ),
                                              if (hasTasks)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 2,
                                                  ),
                                                  width: 4,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : kPrimaryRed,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
