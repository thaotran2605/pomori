// lib/services/pomodoro_log_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PomodoroLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pomodoro_logs';

  // Ghi log khi hoàn thành một session
  Future<void> logSessionCompletion({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime date,
    required int sessionNumber,
    required int totalSessions,
    required int focusTime,
    required int breakTime,
    required int actualDuration, // Thời gian thực tế đã làm (giây)
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'userId': userId,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'date': Timestamp.fromDate(date),
        'sessionNumber': sessionNumber,
        'totalSessions': totalSessions,
        'focusTime': focusTime,
        'breakTime': breakTime,
        'actualDuration': actualDuration,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Lỗi khi ghi log: ${e.toString()}';
    }
  }

  // Ghi log khi hoàn thành toàn bộ task
  Future<void> logTaskCompletion({
    required String userId,
    required String taskId,
    required String taskTitle,
    required DateTime date,
    required int totalSessions,
    required int focusTime,
    required int breakTime,
    required int totalDuration, // Tổng thời gian (giây)
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'userId': userId,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'date': Timestamp.fromDate(date),
        'type': 'task_completion',
        'totalSessions': totalSessions,
        'focusTime': focusTime,
        'breakTime': breakTime,
        'totalDuration': totalDuration,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Lỗi khi ghi log hoàn thành task: ${e.toString()}';
    }
  }

  // Lấy thống kê theo ngày
  Stream<Map<String, dynamic>> getDailyStats(String userId, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    // Fetch user logs and filter by date in memory to avoid composite index requirement
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          int totalSessions = 0;
          int totalFocusTime = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final docDate = (data['date'] as Timestamp).toDate();
            final docDateOnly = DateTime(docDate.year, docDate.month, docDate.day);
            // Filter in memory to ensure we only count logs from the specific day
            if (docDateOnly.year == targetDate.year &&
                docDateOnly.month == targetDate.month &&
                docDateOnly.day == targetDate.day &&
                data['type'] != 'task_completion') {
              totalSessions++;
              totalFocusTime += (data['focusTime'] as int?) ?? 0;
            }
          }

          return {
            'totalSessions': totalSessions,
            'totalFocusTime': totalFocusTime,
          };
        });
  }

  // Lấy thống kê tổng hợp (tất cả thời gian)
  Future<Map<String, dynamic>> getTotalStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      int totalSessions = 0;
      int totalFocusTime = 0; // phút
      int tasksDone = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'task_completion') {
          tasksDone++;
        } else {
          totalSessions++;
          totalFocusTime += (data['focusTime'] as int?) ?? 0;
        }
      }

      return {
        'totalSessions': totalSessions,
        'totalFocusTime': totalFocusTime, // phút
        'tasksDone': tasksDone,
      };
    } catch (e) {
      throw 'Lỗi khi lấy thống kê tổng hợp: ${e.toString()}';
    }
  }

  // Lấy thống kê theo tuần
  Future<Map<String, int>> getWeeklyStats(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      // Fetch user logs and filter by date in memory to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Nhóm theo ngày trong tuần
      final Map<int, int> dailySessions = {};
      final weekStartDateOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEndDateOnly = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        // Filter in memory to ensure we only count logs within the week range
        if (dateOnly.compareTo(weekStartDateOnly) >= 0 && 
            dateOnly.compareTo(weekEndDateOnly) < 0 && 
            data['type'] != 'task_completion') {
          final dayOfWeek = date.weekday; // 1 = Monday, 7 = Sunday
          dailySessions[dayOfWeek] = (dailySessions[dayOfWeek] ?? 0) + 1;
        }
      }

      // Chuyển sang map với key là index trong tuần (0-6, bắt đầu từ Chủ nhật)
      final Map<String, int> result = {};
      for (int i = 0; i < 7; i++) {
        // Chuyển đổi: 0=CN, 1=T2, ..., 6=T7
        // weekday: 1=T2, 2=T3, ..., 7=CN
        int weekday;
        if (i == 0) {
          weekday = 7; // Chủ nhật
        } else {
          weekday = i; // T2-T7
        }
        result['day$i'] = dailySessions[weekday] ?? 0;
      }

      return result;
    } catch (e) {
      throw 'Lỗi khi lấy thống kê tuần: ${e.toString()}';
    }
  }

  // Tính streak (số ngày liên tiếp có hoàn thành session)
  Future<int> getStreak(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Fetch all user logs and filter in memory to avoid composite index requirement
      // This is acceptable since we only need to check recent days for streak
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Group sessions by date, only consider last 365 days for performance
      final Set<DateTime> daysWithSessions = {};
      final cutoffDate = today.subtract(const Duration(days: 365));
      final cutoffDateOnly = DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day);
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        
        // Only count session completions, not task completions
        // Only consider recent dates (within last 365 days) to avoid processing too much data
        if (dateOnly.compareTo(cutoffDateOnly) >= 0 && 
            data['type'] != 'task_completion') {
          daysWithSessions.add(dateOnly);
        }
      }

      // Calculate streak by checking consecutive days backwards from today
      int streak = 0;
      DateTime checkDate = today;

      while (true) {
        if (daysWithSessions.contains(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      throw 'Lỗi khi tính streak: ${e.toString()}';
    }
  }

  // Lấy thống kê theo tuần cho biểu đồ (7 ngày gần nhất)
  Future<List<Map<String, dynamic>>> getWeeklyChartData(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(const Duration(days: 6)); // 7 ngày gần nhất

      // Fetch user logs and filter by date in memory to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Nhóm theo ngày, only consider logs from the last 7 days
      final Map<DateTime, int> dailySessions = {};
      final weekStartDateOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        // Filter in memory to ensure we only count logs from the last 7 days (inclusive)
        if (dateOnly.compareTo(weekStartDateOnly) >= 0 && 
            dateOnly.compareTo(todayDateOnly) <= 0 &&
            data['type'] != 'task_completion') {
          dailySessions[dateOnly] = (dailySessions[dateOnly] ?? 0) + 1;
        }
      }

      // Tạo danh sách 7 ngày gần nhất
      final List<Map<String, dynamic>> result = [];
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final sessions = dailySessions[date] ?? 0;
        final dayName = _getDayName(date.weekday);
        result.add({
          'day': dayName,
          'sessions': sessions,
          'date': date,
        });
      }

      return result;
    } catch (e) {
      throw 'Lỗi khi lấy dữ liệu biểu đồ: ${e.toString()}';
    }
  }

  String _getDayName(int weekday) {
    // weekday: 1 = Monday, 7 = Sunday
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
