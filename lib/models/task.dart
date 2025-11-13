// lib/models/task.dart
class Task {
  final String id;
  final String title;
  final String description;
  final int pomodorosEstimate; // Số Pomodoro dự kiến
  final int pomodorosCompleted; // Số Pomodoro đã hoàn thành
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.pomodorosEstimate = 1,
    this.pomodorosCompleted = 0,
    this.isCompleted = false,
  });

// Khi tích hợp Firebase, bạn sẽ thêm một factory constructor
// để tạo Task từ dữ liệu JSON/Map nhận được từ Firestore.
// factory Task.fromJson(Map<String, dynamic> json) {...}
}