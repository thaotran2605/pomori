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
  Map<String, dynamic>? _filteredStats; // Stats theo time range được chọn
  int _streak = 0;
  List<Map<String, dynamic>>? _chartData;
  DateTime? _firstLogDate;
  String _selectedTimeRange = 'This week';
  DateTime _selectedWeekStart = DateTime.now(); // Tuần được chọn
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo tuần hiện tại
    final now = DateTime.now();
    _selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
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
      final firstLogDate = await _logService.getFirstLogDate(user.uid);
      
      // Load dữ liệu theo time range được chọn
      List<Map<String, dynamic>>? chartData;
      Map<String, dynamic>? filteredStats;
      
      if (_selectedTimeRange == 'Day') {
        // Load dữ liệu theo ngày với các khoảng thời gian 00, 06, 12, 18
        final today = DateTime.now();
        chartData = await _logService.getDailyChartData(user.uid, today);
        filteredStats = await _logService.getDailyStats(user.uid, today);
      } else {
        // Load dữ liệu theo tuần
        chartData = await _logService.getWeeklyChartData(user.uid, _selectedWeekStart);
        filteredStats = await _logService.getWeeklyStats(user.uid, _selectedWeekStart);
      }
      
      final totalStats = await _logService.getTotalStats(user.uid);
      final streak = await _logService.getStreak(user.uid);

      if (mounted) {
        setState(() {
          _totalStats = totalStats;
          _filteredStats = filteredStats;
          _streak = streak;
          _chartData = chartData;
          _firstLogDate = firstLogDate;
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
        title: Row(
          children: [
            Image.asset(
              'assets/images/pomori_logo2.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Statistics',
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
                    // Chart section - Đưa lên trên
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Statistics Graph',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kTextColor,
                                ),
                              ),
                              _TimeRangeDropdown(
                                selectedRange: _selectedTimeRange,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTimeRange = value;
                                    // Reset về tuần hiện tại khi đổi mode
                                    if (value == 'This week') {
                                      final now = DateTime.now();
                                      _selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
                                    }
                                  });
                                  _loadStats();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_chartData != null && _chartData!.isNotEmpty)
                            SizedBox(
                              height: 250,
                              child: _BarChartWithSwipe(
                                data: _chartData!,
                                timeRange: _selectedTimeRange,
                                onSwipeLeft: () {
                                  // Swipe trái: xem tuần trước
                                  if (_selectedTimeRange == 'This week') {
                                    final newWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
                                    setState(() {
                                      _selectedWeekStart = newWeekStart;
                                    });
                                    _loadStats();
                                  }
                                },
                                onSwipeRight: () {
                                  // Swipe phải: về tuần hiện tại (chỉ khi không phải tuần hiện tại)
                                  if (_selectedTimeRange == 'This week') {
                                    final now = DateTime.now();
                                    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                                    if (_selectedWeekStart.isBefore(currentWeekStart)) {
                                      setState(() {
                                        _selectedWeekStart = currentWeekStart;
                                      });
                                      _loadStats();
                                    }
                                  }
                                },
                                canSwipeRight: () {
                                  if (_selectedTimeRange != 'This week') return false;
                                  final now = DateTime.now();
                                  final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                                  return _selectedWeekStart.isBefore(currentWeekStart);
                                },
                              ),
                            )
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
                    const SizedBox(height: 30),
                    // Summary cards - Đưa xuống dưới
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Focus',
                            value: _formatFocusTime(
                                _filteredStats?['totalFocusTime'] ?? _totalStats?['totalFocusTime'] ?? 0),
                            icon: Icons.timer,
                            color: kPrimaryRed,
                            firstLogDate: _firstLogDate,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Sessions',
                            value: '${_filteredStats?['totalSessions'] ?? _totalStats?['totalSessions'] ?? 0}',
                            icon: Icons.check_circle,
                            color: Colors.green,
                            firstLogDate: _firstLogDate,
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
                            value: '${_filteredStats?['tasksDone'] ?? _totalStats?['tasksDone'] ?? 0}',
                            icon: Icons.task_alt,
                            color: Colors.blue,
                            firstLogDate: _firstLogDate,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Streak',
                            value: _streak == 0 ? '0 days' : '$_streak ${_streak == 1 ? 'day' : 'days'}',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                            firstLogDate: _firstLogDate,
                          ),
                        ),
                      ],
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
  final DateTime? firstLogDate;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.firstLogDate,
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
          if (firstLogDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Since ${_formatDate(firstLogDate!)}',
              style: TextStyle(
                fontSize: 11,
                color: kTextColor.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

}

String _formatDate(DateTime date) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _TimeRangeDropdown extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onChanged;

  const _TimeRangeDropdown({
    required this.selectedRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kPrimaryRed,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRange,
          icon: Icon(Icons.arrow_drop_down, color: kPrimaryRed),
          style: TextStyle(
            color: kTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
                              items: const [
            DropdownMenuItem(value: 'Day', child: Text('Day')),
            DropdownMenuItem(value: 'This week', child: Text('This week')),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _BarChartWithSwipe extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String timeRange;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool Function() canSwipeRight;

  const _BarChartWithSwipe({
    required this.data,
    required this.timeRange,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.canSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Tìm giá trị max để scale
    final maxSessions = data.map((d) {
      final value = d['sessions'] ?? d['label'];
      return value is int ? value : 0;
    }).whereType<int>().fold<int>(0, (a, b) => a > b ? a : b);
    final chartMax = maxSessions > 0 ? maxSessions : 8; // Default max là 8 nếu không có data

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            // Swipe right
            if (canSwipeRight()) {
              onSwipeRight();
            }
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            onSwipeLeft();
          }
        }
      },
      child: Container(
        height: 250,
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final item = entry.value;
            final sessions = item['sessions'] as int? ?? 0;
            final label = item['label'] as String? ?? item['day'] as String? ?? '';
            
            // Tính chiều cao của bar dựa trên max value
            final normalizedHeight = chartMax > 0 ? (sessions / chartMax).clamp(0.0, 1.0) : 0.0;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bar với chiều cao động
                    SizedBox(
                      height: 180 * normalizedHeight,
                      child: FractionallySizedBox(
                        widthFactor: 0.6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryRed,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          alignment: Alignment.topCenter,
                          child: sessions > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$sessions',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Label
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
