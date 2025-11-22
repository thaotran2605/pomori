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

  // Lấy thống kê theo ngày (Stream - real-time updates)
  Stream<Map<String, dynamic>> getDailyStatsStream(String userId, DateTime date) {
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
  Future<Map<String, dynamic>> getWeeklyStats(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      // Fetch user logs and filter by date in memory to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final weekStartDateOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEndDateOnly = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);

      // Tính tổng sessions và focus time trong tuần
      int totalSessions = 0;
      int totalFocusTime = 0;
      int tasksDone = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        
        if (dateOnly.compareTo(weekStartDateOnly) >= 0 && 
            dateOnly.compareTo(weekEndDateOnly) < 0) {
          if (data['type'] == 'task_completion') {
            tasksDone++;
          } else {
            totalSessions++;
            totalFocusTime += (data['focusTime'] as int?) ?? 0;
          }
        }
      }

      return {
        'totalSessions': totalSessions,
        'totalFocusTime': totalFocusTime,
        'tasksDone': tasksDone,
      };
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

  // Lấy ngày đầu tiên có dữ liệu thống kê
  Future<DateTime?> getFirstLogDate(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data();
      final date = (data['date'] as Timestamp).toDate();
      return DateTime(date.year, date.month, date.day);
    } catch (e) {
      // Nếu không có index cho orderBy, lấy tất cả và tìm min
      try {
        final snapshot = await _firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isEmpty) {
          return null;
        }

        DateTime? firstDate;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (firstDate == null || dateOnly.isBefore(firstDate)) {
            firstDate = dateOnly;
          }
        }
        return firstDate;
      } catch (e2) {
        return null;
      }
    }
  }

  // Lấy thống kê theo ngày cho biểu đồ (theo các khoảng thời gian 00, 06, 12, 18)
  Future<List<Map<String, dynamic>>> getDailyChartData(String userId, DateTime date) async {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Nhóm theo khoảng thời gian: 00-06, 06-12, 12-18, 18-24
      final Map<int, int> timeSlotSessions = {0: 0, 6: 0, 12: 0, 18: 0};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'task_completion') continue;
        
        final logDate = (data['date'] as Timestamp).toDate();
        final logDateOnly = DateTime(logDate.year, logDate.month, logDate.day);
        
        if (logDateOnly.isAtSameMomentAs(targetDate)) {
          final hour = logDate.hour;
          if (hour >= 0 && hour < 6) {
            timeSlotSessions[0] = (timeSlotSessions[0] ?? 0) + 1;
          } else if (hour >= 6 && hour < 12) {
            timeSlotSessions[6] = (timeSlotSessions[6] ?? 0) + 1;
          } else if (hour >= 12 && hour < 18) {
            timeSlotSessions[12] = (timeSlotSessions[12] ?? 0) + 1;
          } else if (hour >= 18 && hour < 24) {
            timeSlotSessions[18] = (timeSlotSessions[18] ?? 0) + 1;
          }
        }
      }

      return [
        {'label': '00', 'sessions': timeSlotSessions[0] ?? 0},
        {'label': '06', 'sessions': timeSlotSessions[6] ?? 0},
        {'label': '12', 'sessions': timeSlotSessions[12] ?? 0},
        {'label': '18', 'sessions': timeSlotSessions[18] ?? 0},
      ];
    } catch (e) {
      throw 'Lỗi khi lấy dữ liệu biểu đồ ngày: ${e.toString()}';
    }
  }

  // Lấy thống kê theo ngày
  Future<Map<String, dynamic>> getDailyStats(String userId, DateTime date) async {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      int totalSessions = 0;
      int totalFocusTime = 0;
      int tasksDone = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final logDate = (data['date'] as Timestamp).toDate();
        final logDateOnly = DateTime(logDate.year, logDate.month, logDate.day);
        
        if (logDateOnly.isAtSameMomentAs(targetDate)) {
          if (data['type'] == 'task_completion') {
            tasksDone++;
          } else {
            totalSessions++;
            totalFocusTime += (data['focusTime'] as int?) ?? 0;
          }
        }
      }

      return {
        'totalSessions': totalSessions,
        'totalFocusTime': totalFocusTime,
        'tasksDone': tasksDone,
      };
    } catch (e) {
      throw 'Lỗi khi lấy thống kê ngày: ${e.toString()}';
    }
  }

  // Lấy thống kê theo tuần cho biểu đồ
  Future<List<Map<String, dynamic>>> getWeeklyChartData(String userId, DateTime weekStart) async {
    try {
      final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEnd = weekStartDate.add(const Duration(days: 6));

      // Fetch user logs and filter by date in memory to avoid composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Nhóm theo ngày trong tuần
      final Map<DateTime, int> dailySessions = {};
      final weekStartDateOnly = DateTime(weekStartDate.year, weekStartDate.month, weekStartDate.day);
      final weekEndDateOnly = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] == 'task_completion') continue;
        
        final date = (data['date'] as Timestamp).toDate();
        final dateOnly = DateTime(date.year, date.month, date.day);
        // Filter in memory to ensure we only count logs within the week range
        if (dateOnly.compareTo(weekStartDateOnly) >= 0 && 
            dateOnly.compareTo(weekEndDateOnly) <= 0) {
          dailySessions[dateOnly] = (dailySessions[dateOnly] ?? 0) + 1;
        }
      }

      // Tạo danh sách 7 ngày trong tuần
      final List<Map<String, dynamic>> result = [];
      for (int i = 0; i < 7; i++) {
        final date = weekStartDate.add(Duration(days: i));
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
