// lib/views/new_task_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/app_constants.dart';
import '../utils/app_routes.dart';
import '../services/pomodoro_service.dart';
import '../models/pomodoro_task.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  static const routeName = AppRoutes.newTask;

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _pomodoroService = PomodoroService();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _sessions = 1;
  bool _isLoading = false;

  // Focus time và Break time cố định
  static const int _focusTime = 25; // minutes
  static const int _breakTime = 5; // minutes

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selectedDate là hôm nay (chỉ ngày, không có giờ)
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    // Cho phép chọn tất cả ngày (quá khứ, hiện tại, tương lai)
    // Chỉ chặn khi tạo task
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Cho phép chọn từ năm 2020
      lastDate: DateTime(2030), // Đến năm 2030
    );
    
    if (picked != null) {
      final pickedOnly = DateTime(picked.year, picked.month, picked.day);
      if (!pickedOnly.isAtSameMomentAs(_selectedDate)) {
        setState(() {
          _selectedDate = pickedOnly;
        });
      }
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage('Vui lòng đăng nhập để tạo task.');
        return;
      }

      // Kiểm tra không cho tạo task vào ngày đã qua
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);
      final selectedDateOnly = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      
      // Kiểm tra nghiêm ngặt: selectedDate phải >= today
      // Chỉ cho phép tạo task từ ngày hôm nay trở đi
      if (selectedDateOnly.isBefore(todayOnly)) {
        _showMessage('Không thể tạo task vào ngày đã qua! Vui lòng chọn ngày hôm nay hoặc tương lai.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tạo DateTime cho startTime từ date và time đã chọn
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Kiểm tra nếu chọn hôm nay thì startTime phải sau thời điểm hiện tại
      if (selectedDateOnly == todayOnly) {
        final now = DateTime.now();
        if (startTime.isBefore(now)) {
          _showMessage('Thời gian bắt đầu phải sau thời điểm hiện tại!');
          return;
        }
      }

      final task = PomodoroTask(
        userId: user.uid,
        title: _taskNameController.text.trim(),
        date: _selectedDate,
        startTime: startTime,
        sessions: _sessions,
        focusTime: _focusTime,
        breakTime: _breakTime,
      );

      await _pomodoroService.createPomodoroTask(task);

      if (!mounted) return;
      _showMessage('Tạo task thành công!', isError: false);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi khi tạo task: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        backgroundColor: kLightBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Task',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task name
                _buildLabel('Task name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _taskNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Study Math',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFFFF0F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên task';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                // Date
                _buildLabel('Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Start time
                _buildLabel('Start time'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Icon(Icons.access_time, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Session
                _buildLabel('Session'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.grey),
                        onPressed: () {
                          if (_sessions > 1) {
                            setState(() {
                              _sessions--;
                            });
                          }
                        },
                      ),
                      Text(
                        '$_sessions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(80, 80, 80, 1),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _sessions++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Focus time (fixed)
                _TimeDisplay(
                  label: 'Focus time',
                  icon: Icons.access_time,
                  time: '$_focusTime minutes',
                ),
                const SizedBox(height: 15),
                // Break time (fixed)
                _TimeDisplay(
                  label: 'Break time',
                  icon: Icons.coffee_rounded,
                  time: '$_breakTime minutes',
                ),
                const SizedBox(height: 40),
                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Create New Task',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;

  const _TimeDisplay({
    required this.label,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 10),
              Text(
                time,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
