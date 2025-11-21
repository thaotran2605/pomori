import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/pomodoro_task.dart';
import '../services/pomodoro_log_service.dart';
import '../services/pomodoro_service.dart';
import 'ui_message.dart';

class TimerViewModel extends ChangeNotifier {
  TimerViewModel({
    PomodoroService? pomodoroService,
    PomodoroLogService? logService,
    FirebaseAuth? firebaseAuth,
  }) : _pomodoroService = pomodoroService ?? PomodoroService(),
       _logService = logService ?? PomodoroLogService(),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final PomodoroService _pomodoroService;
  final PomodoroLogService _logService;
  final FirebaseAuth _firebaseAuth;

  PomodoroTask? _task;
  Timer? _timer;

  int _remainingSeconds = 0;
  int _currentSessionIndex = 0;
  bool _isFocusPhase = true;
  bool _isPaused = false;
  bool _isRunning = false;
  int _totalElapsedSeconds = 0;
  DateTime? _phaseStartTime; // Thời gian bắt đầu phase hiện tại

  PomodoroTask? _completedTask;
  UiMessage? _pendingMessage;

  PomodoroTask? get task => _task;
  int get currentSession => _currentSessionIndex + 1;
  int get totalSessions => _task?.sessions ?? 0;
  bool get isFocusPhase => _isFocusPhase;
  bool get isPaused => _isPaused;
  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  double get progressValue {
    if (_task == null) return 0.0;
    final totalSeconds = _isFocusPhase
        ? _task!.focusTime * 60
        : _task!.breakTime * 60;
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  String get timeRemaining {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  UiMessage? consumeMessage() {
    final message = _pendingMessage;
    _pendingMessage = null;
    return message;
  }

  PomodoroTask? consumeCompletedTask() {
    final completed = _completedTask;
    _completedTask = null;
    return completed;
  }

  void initialize(PomodoroTask task) {
    if (_task != null) return;
    _task = task;
    _currentSessionIndex = task.currentSession;
    _isRunning = false;
    _isPaused = false;
    _totalElapsedSeconds = 0;

    // Khôi phục trạng thái timer nếu có
    if (task.timerStartedAt != null && 
        task.timerRemainingSeconds != null && 
        task.timerIsFocusPhase != null) {
      // Tính toán thời gian còn lại dựa trên thời gian đã trôi qua
      final now = DateTime.now();
      final elapsed = now.difference(task.timerStartedAt!).inSeconds;
      final savedRemaining = task.timerRemainingSeconds!;
      final calculatedRemaining = savedRemaining - elapsed;
      
      if (calculatedRemaining > 0) {
        // Timer vẫn còn thời gian, khôi phục trạng thái
        _remainingSeconds = calculatedRemaining;
        _isFocusPhase = task.timerIsFocusPhase!;
        _phaseStartTime = task.timerStartedAt; // Khôi phục thời gian bắt đầu phase
        // Không set _isRunning = true ở đây, để _startTimer() tự động start
      } else {
        // Timer đã hết thời gian, reset về phase mới
        _isFocusPhase = task.timerIsFocusPhase!;
        if (_isFocusPhase) {
          // Đã hết focus, chuyển sang break hoặc session tiếp theo
          _onPhaseComplete();
        } else {
          // Đã hết break, chuyển sang focus session tiếp theo
          _currentSessionIndex++;
          _isFocusPhase = true;
          _remainingSeconds = task.focusTime * 60;
          _phaseStartTime = DateTime.now();
        }
      }
    } else {
      // Không có trạng thái lưu, khởi tạo mới
      _isFocusPhase = true;
      _remainingSeconds = task.focusTime * 60;
      _phaseStartTime = DateTime.now();
    }

    _ensureActiveTask();
    _startTimer();
  }

  Future<void> togglePause() async {
    if (!_isRunning && !_isPaused) {
      // Chưa chạy, bắt đầu timer
      _startTimer();
      return;
    }

    if (_isPaused) {
      // Đang pause, resume timer
      _isPaused = false;
      _resumeTimer();
    } else {
      // Đang chạy, pause timer
      _isPaused = true;
      _timer?.cancel();
      _saveTimerState(); // Lưu trạng thái khi pause
    }
    notifyListeners();
  }

  Future<void> skipPhase() async {
    _timer?.cancel();
    _onPhaseComplete(autoContinue: false);
    // Không tự động start sau khi skip - người dùng phải bấm pause để start
  }

  Future<void> stopTimer() async {
    _timer?.cancel();
    _isRunning = false;
    await _clearTimerState();
    await _clearActiveTask();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_task == null) return;
    
    // Nếu đang chạy rồi thì không start lại
    if (_isRunning && !_isPaused) return;

    _isRunning = true;
    _isPaused = false;
    
    // Lưu trạng thái timer vào Firestore
    _saveTimerState();
    
    _phaseStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _totalElapsedSeconds++;
        notifyListeners();
      } else {
        _onPhaseComplete(autoContinue: true);
      }
    });
    notifyListeners();
  }

  void _resumeTimer() {
    if (_task == null) return;
    
    // Resume timer từ trạng thái pause
    _phaseStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _totalElapsedSeconds++;
        notifyListeners();
      } else {
        _onPhaseComplete(autoContinue: true);
      }
    });
    _saveTimerState();
    notifyListeners();
  }

  Future<void> refillTime() async {
    // Reset thời gian về ban đầu của phase hiện tại
    if (_task == null) return;
    
    _timer?.cancel();
    
    if (_isFocusPhase) {
      _remainingSeconds = _task!.focusTime * 60;
    } else {
      _remainingSeconds = _task!.breakTime * 60;
    }
    
    _phaseStartTime = DateTime.now();
    _saveTimerState();
    
    // Nếu đang chạy, tiếp tục chạy; nếu đang pause, giữ nguyên pause
    if (_isRunning && !_isPaused) {
      _resumeTimer();
    }
    
    notifyListeners();
  }

  void _onPhaseComplete({bool autoContinue = true}) {
    if (_task == null) return;

    // Dừng timer khi chuyển phase
    _timer?.cancel();

    if (_isFocusPhase) {
      _logSessionCompletion();

      if (_currentSessionIndex >= _task!.sessions - 1) {
        _completeTask();
        return;
      }

      _isFocusPhase = false;
      _remainingSeconds = _task!.breakTime * 60;
      _phaseStartTime = DateTime.now();
      _saveTimerState(); // Lưu khi chuyển phase
    } else {
      _currentSessionIndex++;
      _isFocusPhase = true;
      _remainingSeconds = _task!.focusTime * 60;
      _phaseStartTime = DateTime.now();
      _updateCurrentSession();
      _saveTimerState(); // Lưu khi chuyển phase
    }

    // Nếu autoContinue = true (tự động hết thời gian), tiếp tục chạy
    // Nếu autoContinue = false (bấm next session), dừng lại
    if (autoContinue) {
      _isRunning = true;
      _isPaused = false;
      _resumeTimer();
    } else {
      _isRunning = false;
      _isPaused = false;
    }

    notifyListeners();
  }

  Future<void> _logSessionCompletion() async {
    if (_task == null) return;

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      await _logService.logSessionCompletion(
        userId: user.uid,
        taskId: _task!.id ?? '',
        taskTitle: _task!.title,
        date: _task!.date,
        sessionNumber: _currentSessionIndex + 1,
        totalSessions: _task!.sessions,
        focusTime: _task!.focusTime,
        breakTime: _task!.breakTime,
        actualDuration: _task!.focusTime * 60,
      );
    } catch (e) {
      debugPrint('Error logging session: $e');
    }
  }

  Future<void> _updateCurrentSession() async {
    if (_task?.id == null) return;

    try {
      await _pomodoroService.updateCurrentSession(
        _task!.id!,
        _currentSessionIndex + 1,
      );
    } catch (e) {
      debugPrint('Error updating session: $e');
    }
  }

  Future<void> _completeTask() async {
    _timer?.cancel();

    if (_task == null) return;

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        if (_task!.id != null) {
          await _pomodoroService.markAsCompleted(_task!.id!);
        }

        await _logService.logTaskCompletion(
          userId: user.uid,
          taskId: _task!.id ?? '',
          taskTitle: _task!.title,
          date: _task!.date,
          totalSessions: _task!.sessions,
          focusTime: _task!.focusTime,
          breakTime: _task!.breakTime,
          totalDuration: _totalElapsedSeconds,
        );

        await _clearTimerState();
        await _pomodoroService.clearActiveTask(user.uid, taskId: _task!.id);
      }

      _completedTask = _task;
      notifyListeners();
    } catch (e) {
      _setMessage('Lỗi khi hoàn thành task: $e');
    }
  }

  Future<void> _ensureActiveTask() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || _task?.id == null) return;
    try {
      await _pomodoroService.setActiveTask(user.uid, _task!.id!);
    } catch (e) {
      debugPrint('Không thể cập nhật task đang chạy: $e');
    }
  }

  Future<void> _clearActiveTask() async {
    final user = _firebaseAuth.currentUser;
    if (user == null || _task?.id == null) return;
    try {
      await _pomodoroService.clearActiveTask(user.uid, taskId: _task!.id);
    } catch (e) {
      debugPrint('Không thể xóa trạng thái task đang chạy: $e');
    }
  }

  Future<void> _saveTimerState() async {
    if (_task?.id == null || !_isRunning || _phaseStartTime == null) return;
    
    try {
      // Lưu thời gian bắt đầu phase và thời gian còn lại
      await _pomodoroService.saveTimerState(
        taskId: _task!.id!,
        timerStartedAt: _phaseStartTime!,
        remainingSeconds: _remainingSeconds,
        isFocusPhase: _isFocusPhase,
      );
    } catch (e) {
      debugPrint('Lỗi khi lưu trạng thái timer: $e');
    }
  }

  Future<void> _clearTimerState() async {
    if (_task?.id == null) return;
    
    try {
      await _pomodoroService.clearTimerState(_task!.id!);
    } catch (e) {
      debugPrint('Lỗi khi xóa trạng thái timer: $e');
    }
  }

  void _setMessage(String text, {bool isError = true}) {
    _pendingMessage = UiMessage(text, isError: isError);
    notifyListeners();
  }
}
