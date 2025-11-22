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
  Map<String, dynamic>? _previousWeekStats; // Stats tuần trước để so sánh
  int _streak = 0;
  List<Map<String, dynamic>>? _chartData;
  String _selectedTimeRange = 'This week';
  DateTime _selectedWeekStart = DateTime.now(); // Tuần được chọn
  double? _averageFocusTime; // Trung bình thời gian focus
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
      // Load dữ liệu theo time range được chọn
      List<Map<String, dynamic>>? chartData;
      Map<String, dynamic>? filteredStats;
      
      if (_selectedTimeRange == 'Day') {
        // Load dữ liệu theo ngày với các khoảng thời gian 00, 06, 12, 18
        final today = DateTime.now();
        chartData = await _logService.getDailyChartData(user.uid, today);
        filteredStats = await _logService.getDailyStats(user.uid, today);
        _previousWeekStats = null; // Không so sánh cho Day mode
        // Tính trung bình cho Day mode
        if (chartData.isNotEmpty) {
          final totalSessions = chartData.fold<int>(0, (sum, item) => sum + (item['sessions'] as int? ?? 0));
          final totalFocusTime = filteredStats['totalFocusTime'] as int? ?? 0;
          _averageFocusTime = totalSessions > 0 ? totalFocusTime / totalSessions : 0;
        } else {
          _averageFocusTime = 0;
        }
      } else {
        // Load dữ liệu theo tuần
        chartData = await _logService.getWeeklyChartData(user.uid, _selectedWeekStart);
        filteredStats = await _logService.getWeeklyStats(user.uid, _selectedWeekStart);
        
        // Load dữ liệu tuần trước để so sánh (chỉ khi ở This week)
        if (_selectedTimeRange == 'This week') {
          final previousWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
          _previousWeekStats = await _logService.getWeeklyStats(user.uid, previousWeekStart);
        } else {
          _previousWeekStats = null;
        }
        
        // Tính trung bình cho Week mode
        if (chartData.isNotEmpty) {
          final totalSessions = chartData.fold<int>(0, (sum, item) => sum + (item['sessions'] as int? ?? 0));
          final totalFocusTime = filteredStats['totalFocusTime'] as int? ?? 0;
          _averageFocusTime = totalSessions > 0 ? totalFocusTime / totalSessions : 0;
        } else {
          _averageFocusTime = 0;
        }
      }
      
      final totalStats = await _logService.getTotalStats(user.uid);
      final streak = await _logService.getStreak(user.uid);

      if (mounted) {
        setState(() {
          _totalStats = totalStats;
          _filteredStats = filteredStats;
          _previousWeekStats = _previousWeekStats;
          _streak = streak;
          _chartData = chartData;
          _averageFocusTime = _averageFocusTime;
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
                                    // Set tuần tương ứng với lựa chọn
                                    final now = DateTime.now();
                                    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
                                    
                                    if (value == 'This week') {
                                      _selectedWeekStart = currentWeekStart;
                                    } else if (value == 'Last week') {
                                      _selectedWeekStart = currentWeekStart.subtract(const Duration(days: 7));
                                    } else if (value == 'Two weeks ago') {
                                      _selectedWeekStart = currentWeekStart.subtract(const Duration(days: 14));
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
                                averageFocusTime: _averageFocusTime ?? 0,
                                onSwipeLeft: () {
                                  // Swipe trái: xem tuần trước (chỉ khi ở This week mode)
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
                    // So sánh với tuần trước (chỉ hiển thị khi ở week mode)
                    if (_selectedTimeRange != 'Day' && _previousWeekStats != null)
                      _ComparisonCard(
                        currentFocusTime: (_filteredStats?['totalFocusTime'] as int?) ?? 0,
                        previousFocusTime: (_previousWeekStats?['totalFocusTime'] as int?) ?? 0,
                      ),
                    if (_selectedTimeRange != 'Day' && _previousWeekStats != null)
                      const SizedBox(height: 20),
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
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Sessions',
                            value: '${_filteredStats?['totalSessions'] ?? _totalStats?['totalSessions'] ?? 0}',
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
                            value: '${_filteredStats?['tasksDone'] ?? _totalStats?['tasksDone'] ?? 0}',
                            icon: Icons.task_alt,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _StatCard(
                            title: 'Average Focus',
                            value: _averageFocusTime != null 
                                ? _formatFocusTime(_averageFocusTime!.round())
                                : '0m',
                            icon: Icons.trending_up,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Streak',
                            value: _streak == 0 ? '0 days' : '$_streak ${_streak == 1 ? 'day' : 'days'}',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(child: SizedBox()), // Placeholder để giữ layout
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

class _ComparisonCard extends StatelessWidget {
  final int currentFocusTime;
  final int previousFocusTime;

  const _ComparisonCard({
    required this.currentFocusTime,
    required this.previousFocusTime,
  });

  @override
  Widget build(BuildContext context) {
    final difference = currentFocusTime - previousFocusTime;
    final percentage = previousFocusTime > 0 
        ? ((difference / previousFocusTime) * 100).abs()
        : (currentFocusTime > 0 ? 100.0 : 0.0);
    final isIncrease = difference > 0;
    final isDecrease = difference < 0;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(
            isIncrease 
                ? Icons.trending_up 
                : isDecrease 
                    ? Icons.trending_down 
                    : Icons.remove,
            color: isIncrease 
                ? Colors.green 
                : isDecrease 
                    ? Colors.red 
                    : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compared to last week',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isIncrease
                      ? 'Increased by ${percentage.toStringAsFixed(1)}%'
                      : isDecrease
                          ? 'Decreased by ${percentage.toStringAsFixed(1)}%'
                          : 'No change',
                  style: TextStyle(
                    fontSize: 12,
                    color: isIncrease
                        ? Colors.green
                        : isDecrease
                            ? Colors.red
                            : Colors.grey,
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
            DropdownMenuItem(value: 'Last week', child: Text('Last week')),
            DropdownMenuItem(value: 'Two weeks ago', child: Text('Two weeks ago')),
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
  final double averageFocusTime;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool Function() canSwipeRight;

  const _BarChartWithSwipe({
    required this.data,
    required this.timeRange,
    required this.averageFocusTime,
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
    
    // Tính vị trí đường trung bình (dựa trên số sessions trung bình)
    // Giả sử mỗi session là 25 phút, tính số sessions trung bình
    final averageSessions = averageFocusTime > 0 ? (averageFocusTime / 25).round() : 0;
    final averageHeight = chartMax > 0 ? (averageSessions / chartMax).clamp(0.0, 1.0) : 0.0;

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
      child: Stack(
        children: [
          Container(
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
          // Đường kẻ trung bình
          if (averageHeight > 0 && averageHeight < 1.0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 30 + (180 * (1 - averageHeight)),
              child: Container(
                height: 1,
                color: Colors.blue.withOpacity(0.6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.blue.withOpacity(0.6),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Avg: $averageSessions',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.blue.withOpacity(0.6),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
