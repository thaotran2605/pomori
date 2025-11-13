import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hoàn thành định nghĩa 5 icon
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // 0
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Tasks'), // 1
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'New'), // 2 (Icon '+')
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_sharp), label: 'Stats'), // 3
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'), // 4
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFF75F5C), // Sử dụng màu đỏ của nút Start
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // Quan trọng để hiển thị tất cả 5 items
      showSelectedLabels: false, // Ẩn label để giống với thiết kế trong ảnh
      showUnselectedLabels: false,
      backgroundColor: Colors.white, // Màu nền trắng
      elevation: 10,
    );
  }
}