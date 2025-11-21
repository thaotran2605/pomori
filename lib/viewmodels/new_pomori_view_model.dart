import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/pomodoro_task.dart';
import '../services/pomodoro_service.dart';
import 'ui_message.dart';

class NewPomoriResult {
  final PomodoroTask task;
  final bool isExistingTask;

  const NewPomoriResult({required this.task, required this.isExistingTask});
}

class NewPomoriViewModel extends ChangeNotifier {
  NewPomoriViewModel({
    PomodoroService? pomodoroService,
    FirebaseAuth? firebaseAuth,
  }) : _pomodoroService = pomodoroService ?? PomodoroService(),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final PomodoroService _pomodoroService;
  final FirebaseAuth _firebaseAuth;

  static const int focusTime = 25;
  static const int breakTime = 5;

  int _sessions = 1;
  bool _isLoading = false;
  UiMessage? _pendingMessage;

  int get sessions => _sessions;
  bool get isLoading => _isLoading;

  UiMessage? consumeMessage() {
    final message = _pendingMessage;
    _pendingMessage = null;
    return message;
  }

  void increaseSessions() {
    if (_sessions >= 8) return;
    _sessions++;
    notifyListeners();
  }

  void decreaseSessions() {
    if (_sessions <= 1) return;
    _sessions--;
    notifyListeners();
  }

  Future<PomodoroTask?> fetchActiveTask() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      _setMessage('Bạn cần đăng nhập để tiếp tục.');
      return null;
    }

    try {
      return await _pomodoroService.getActiveTask(user.uid);
    } catch (e) {
      _setMessage('Không thể kiểm tra Pomodoro đang chạy: $e');
      return null;
    }
  }

  Future<NewPomoriResult?> startPomodoro(String taskName) async {
    final trimmedName = taskName.trim();
    if (trimmedName.isEmpty) {
      _setMessage('Tên task không được để trống.');
      return null;
    }

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      _setMessage('Bạn cần đăng nhập để bắt đầu Pomodoro.');
      return null;
    }

    _setLoading(true);
    try {
      final activeTask = await _pomodoroService.getActiveTask(user.uid);
      if (activeTask != null) {
        _setMessage(
          'Bạn đang có Pomodoro đang chạy. Chuyển đến timer...',
          isError: false,
        );
        return NewPomoriResult(task: activeTask, isExistingTask: true);
      }

      final now = DateTime.now();
      final newTask = PomodoroTask(
        userId: user.uid,
        title: trimmedName,
        date: now,
        startTime: now,
        sessions: _sessions,
        focusTime: focusTime,
        breakTime: breakTime,
      );

      final taskId = await _pomodoroService.createPomodoroTask(newTask);
      await _pomodoroService.setActiveTask(user.uid, taskId);

      _setMessage(
        'Bắt đầu Pomodoro mới! Chúc bạn tập trung tốt.',
        isError: false,
      );

      return NewPomoriResult(
        task: newTask.copyWith(id: taskId, isRunning: true),
        isExistingTask: false,
      );
    } catch (e) {
      _setMessage('Không thể bắt đầu Pomodoro: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage(String text, {bool isError = true}) {
    _pendingMessage = UiMessage(text, isError: isError);
    notifyListeners();
  }
}
