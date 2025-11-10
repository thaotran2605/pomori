import 'package:flutter/material.dart';
// Giả định bottom_nav_bar.dart ở trong views/widgets/
import '../widgets/bottom_nav_bar.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Dữ liệu mô phỏng
  final String taskName = "Reading Books";
  final String totalTime = "120 minutes";
  final int totalSessions = 4;
  final int currentSession = 2;
  final int focusMinutes = 25;

  // Trạng thái mô phỏng
  double _progressValue = 0.78; // Mô phỏng 18:59/25:00
  String _timeRemaining = "18:59";
  bool _isPaused = false;
  int _currentIndex = 0; // Đặt chỉ mục về Home/Timer

  void _onTapNavBar(int index) {
    setState(() {
      _currentIndex = index;
    });
    print('Navigating from Timer to tab $index');
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      print(_isPaused ? 'Timer Paused' : 'Timer Resumed');
    });
  }

  void _stopTimer() {
    print('Timer Stopped. Navigating back to New Pomori screen.');
    // Logic thực tế: Dừng đếm ngược và quay lại màn hình trước
  }

  void _skipSession() {
    print('Session Skipped. Starting next session/break.');
    // Logic thực tế: Chuyển sang phiên tiếp theo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDEDE3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pomori Timer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. Task Card ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      taskName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalTime',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // --- 2. Timer Ring ---
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vòng tròn xám nền
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 10),
                      ),
                    ),
                    // Vòng tròn tiến độ (màu xanh lá)
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: _progressValue,
                        strokeWidth: 10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF81C784)), // Màu xanh lá
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // Nội dung trung tâm
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _timeRemaining,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$currentSession of $totalSessions sessions',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // --- 3. Status Text ---
              Text(
                'Stay focus for $focusMinutes minutes',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 50),

              // --- 4. Control Buttons (Stop | Play/Pause | Skip) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút Stop
                  _ControlCircleButton(
                    icon: Icons.stop,
                    color: Colors.red.shade300,
                    onPressed: _stopTimer,
                  ),
                  const SizedBox(width: 25),
                  // Nút Play/Pause
                  _ControlCircleButton(
                    icon: _isPaused ? Icons.play_arrow : Icons.pause,
                    color: const Color(0xFFF75F5C),
                    size: 80, // Nút lớn hơn
                    onPressed: _togglePause,
                  ),
                  const SizedBox(width: 25),
                  // Nút Skip
                  _ControlCircleButton(
                    icon: Icons.skip_next,
                    color: Colors.grey.shade400,
                    onPressed: _skipSession,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTapNavBar,
      ),
    );
  }
}

// Widget con cho các nút điều khiển hình tròn
class _ControlCircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  const _ControlCircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.45),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}