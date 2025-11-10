// lib/services/mock_task_service.dart
import '../models/task.dart';

class MockTaskService {
  // Dữ liệu mẫu (Mock Data)
  final List<Task> _mockTasks = [
    Task(
      id: '1',
      title: 'Hoàn thành code Front-end',
      pomodorosEstimate: 4,
      pomodorosCompleted: 1,
    ),
    Task(
      id: '2',
      title: 'Viết tài liệu về dự án Pomori',
      pomodorosEstimate: 2,
      isCompleted: true,
    ),
    Task(
      id: '3',
      title: 'Ôn tập kiến thức Flutter',
      pomodorosEstimate: 3,
    ),
  ];

  // Hàm giả lập lấy tất cả công việc (trả về một Future)
  Future<List<Task>> fetchTasks() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(seconds: 1));
    return _mockTasks;
  }

  // Hàm giả lập thêm công việc
  Future<void> addTask(Task newTask) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockTasks.add(newTask);
  }

// Bạn sẽ thêm các hàm giả lập khác như updateTask, deleteTask, v.v.
}