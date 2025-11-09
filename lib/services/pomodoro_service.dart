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

  // Lấy danh sách Pomodoro của user
  Stream<List<PomodoroTask>> getPomodoroTasks(String userId) {
    // Bỏ orderBy để tránh lỗi index, sort hoàn toàn trong code
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => PomodoroTask.fromFirestore(
                doc.data(),
                doc.id,
              ))
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
}

