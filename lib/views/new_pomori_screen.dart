import 'package:flutter/material.dart';
// Thay đổi import nếu file bottom_nav_bar.dart ở vị trí khác
import '../widgets/bottom_nav_bar.dart';

class NewPomoriScreen extends StatelessWidget {
  const NewPomoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NewPomoriScreenContent();
  }
}

class _NewPomoriScreenContent extends StatelessWidget {
  const _NewPomoriScreenContent();

  static void _handleNavigationTap(int index) {
    print('Navigating to tab $index');
  }

  void _onStartPressed() {
    print('Start Pomodoro! Ready to switch to Timer Screen.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEDE3),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header (ĐÃ DÙNG LOGO ASSET) ---
              Row(
                children: [
                  // THAY THẾ TEXT BẰNG IMAGE.ASSET
                  Image.asset(
                    'assets/images/pomori_logo2.png', // Đường dẫn logo
                    width: 40, // Đặt kích thước phù hợp
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'New Pomori',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- 2. Input Card Container ---
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TaskNameInput(),
                    const SizedBox(height: 25),
                    const _SessionControl(),
                    const SizedBox(height: 25),
                    const _TimeDisplay(
                      label: 'Focus time',
                      icon: Icons.access_time,
                      time: '25 minutes',
                    ),
                    const SizedBox(height: 15),
                    const _TimeDisplay(
                      label: 'Break time',
                      icon: Icons.coffee_rounded,
                      time: '5 minutes',
                    ),
                    const SizedBox(height: 40),
                    _StartButton(onPressed: _onStartPressed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // --- 3. Bottom NavBar ---
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
        onTap: _handleNavigationTap,
      ),
    );
  }
}

// ----------------------------------------------------
// --- WIDGET CON CHO CÁC PHẦN TỬ TRONG CARD ---
// ----------------------------------------------------

class _TaskNameInput extends StatelessWidget {
  const _TaskNameInput();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Study Math',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFFFF0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }
}

class _SessionControl extends StatelessWidget {
  const _SessionControl();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.remove, color: Colors.grey),
              Text(
                '3',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(80, 80, 80, 1)),
              ),
              Icon(Icons.add, color: Colors.grey),
            ],
          ),
        ),
      ],
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

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF75F5C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Start',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}