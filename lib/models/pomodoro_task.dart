import 'package:cloud_firestore/cloud_firestore.dart';

class PomodoroTask {
  final String? id; // Document ID từ Firestore
  final String userId; // ID của user sở hữu task này
  final String title; // Tiêu đề nhiệm vụ
  final DateTime date; // Ngày thực hiện
  final DateTime startTime; // Thời gian bắt đầu
  final int sessions; // Số phiên Pomodoro
  final int focusTime; // Thời gian tập trung mỗi phiên (phút)
  final int breakTime; // Thời gian nghỉ mỗi phiên (phút)
  final bool isCompleted; // Trạng thái hoàn thành
  final int currentSession; // Phiên hiện tại (0 = chưa bắt đầu)
  final DateTime createdAt; // Thời gian tạo task

  PomodoroTask({
    this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.startTime,
    this.sessions = 3,
    this.focusTime = 25,
    this.breakTime = 5,
    this.isCompleted = false,
    this.currentSession = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert từ Firestore document
  factory PomodoroTask.fromFirestore(Map<String, dynamic> data, String id) {
    return PomodoroTask(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      sessions: data['sessions'] ?? 3,
      focusTime: data['focusTime'] ?? 25,
      breakTime: data['breakTime'] ?? 5,
      isCompleted: data['isCompleted'] ?? false,
      currentSession: data['currentSession'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert sang Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'sessions': sessions,
      'focusTime': focusTime,
      'breakTime': breakTime,
      'isCompleted': isCompleted,
      'currentSession': currentSession,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with method để cập nhật task
  PomodoroTask copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? date,
    DateTime? startTime,
    int? sessions,
    int? focusTime,
    int? breakTime,
    bool? isCompleted,
    int? currentSession,
    DateTime? createdAt,
  }) {
    return PomodoroTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      sessions: sessions ?? this.sessions,
      focusTime: focusTime ?? this.focusTime,
      breakTime: breakTime ?? this.breakTime,
      isCompleted: isCompleted ?? this.isCompleted,
      currentSession: currentSession ?? this.currentSession,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

