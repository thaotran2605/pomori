import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomori/models/pomodoro_task.dart';

class PomodoroService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pomodoro_tasks';

  // Tạo Pomodoro mới
  Future<String> createPomodoroTask(PomodoroTask task) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(task.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo Pomodoro: ${e.toString()}';
    }
  }

  Future<PomodoroTask?> getActiveTask(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRunning', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return PomodoroTask.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      throw 'Lỗi khi lấy Pomodoro đang chạy: ${e.toString()}';
    }
  }

  Future<void> setActiveTask(String userId, String taskId) async {
    try {
      final batch = _firestore.batch();

      // Tắt các task đang chạy khác
      final activeDocs = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRunning', isEqualTo: true)
          .get();

      for (final doc in activeDocs.docs) {
        if (doc.id != taskId) {
          batch.update(doc.reference, {'isRunning': false});
        }
      }

      final targetRef = _firestore.collection(_collection).doc(taskId);
      batch.update(targetRef, {'isRunning': true});

      await batch.commit();
    } catch (e) {
      throw 'Lỗi khi cập nhật Pomodoro đang chạy: ${e.toString()}';
    }
  }

  Future<void> clearActiveTask(String userId, {String? taskId}) async {
    try {
      if (taskId != null) {
        await _firestore.collection(_collection).doc(taskId).update({
          'isRunning': false,
        });
        return;
      }

      final activeDocs = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRunning', isEqualTo: true)
          .get();

      for (final doc in activeDocs.docs) {
        await doc.reference.update({'isRunning': false});
      }
    } catch (e) {
      throw 'Lỗi khi xóa trạng thái Pomodoro đang chạy: ${e.toString()}';
    }
  }

  // Lấy danh sách Pomodoro của user
  Stream<List<PomodoroTask>> getPomodoroTasks(String userId) {
    // Bỏ orderBy để tránh lỗi index, sort hoàn toàn trong code
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => PomodoroTask.fromFirestore(doc.data(), doc.id))
              .toList();

          // Sort trong code: theo date, sau đó theo startTime
          tasks.sort((a, b) {
            final dateCompare = a.date.compareTo(b.date);
            if (dateCompare != 0) return dateCompare;
            return a.startTime.compareTo(b.startTime);
          });

          return tasks;
        });
  }

  // Lấy Pomodoro theo ID
  Future<PomodoroTask?> getPomodoroById(String taskId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(taskId).get();
      if (doc.exists) {
        return PomodoroTask.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy Pomodoro: ${e.toString()}';
    }
  }

  // Cập nhật Pomodoro
  Future<void> updatePomodoroTask(PomodoroTask task) async {
    if (task.id == null) {
      throw 'Task ID không được để trống';
    }
    try {
      await _firestore
          .collection(_collection)
          .doc(task.id)
          .update(task.toFirestore());
    } catch (e) {
      throw 'Lỗi khi cập nhật Pomodoro: ${e.toString()}';
    }
  }

  // Xóa Pomodoro
  Future<void> deletePomodoroTask(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).delete();
    } catch (e) {
      throw 'Lỗi khi xóa Pomodoro: ${e.toString()}';
    }
  }

  // Đánh dấu hoàn thành
  Future<void> markAsCompleted(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'isCompleted': true,
      });
    } catch (e) {
      throw 'Lỗi khi đánh dấu hoàn thành: ${e.toString()}';
    }
  }

  // Cập nhật session hiện tại
  Future<void> updateCurrentSession(String taskId, int session) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'currentSession': session,
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật session: ${e.toString()}';
    }
  }

  // Lưu trạng thái timer
  Future<void> saveTimerState({
    required String taskId,
    required DateTime timerStartedAt,
    required int remainingSeconds,
    required bool isFocusPhase,
  }) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'timerStartedAt': Timestamp.fromDate(timerStartedAt),
        'timerRemainingSeconds': remainingSeconds,
        'timerIsFocusPhase': isFocusPhase,
      });
    } catch (e) {
      throw 'Lỗi khi lưu trạng thái timer: ${e.toString()}';
    }
  }

  // Xóa trạng thái timer (khi hoàn thành hoặc dừng)
  Future<void> clearTimerState(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'timerStartedAt': FieldValue.delete(),
        'timerRemainingSeconds': FieldValue.delete(),
        'timerIsFocusPhase': FieldValue.delete(),
      });
    } catch (e) {
      throw 'Lỗi khi xóa trạng thái timer: ${e.toString()}';
    }
  }
}
