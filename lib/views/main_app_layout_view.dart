// File: views/main_app_layout_view.dart

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart'; // <<< NHẬP WIDGET CON VÀO ĐÂY

// Import 7 màn hình nội dung...

class MainAppLayoutView extends StatefulWidget {
  // ... Code quản lý trạng thái
  @override
  State<MainAppLayoutView> createState() => _MainAppLayoutViewState();
}

class _MainAppLayoutViewState extends State<MainAppLayoutView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // 7 màn hình nội dung của bạn...
    // Ví dụ: TimerScreen(), TaskListScreen(), ...
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // GỌI VÀ SỬ DỤNG WIDGET CON BẠN VỪA TẠO
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, // Truyền trạng thái hiện tại
        onTap: _onItemTapped,       // Truyền hàm callback để cập nhật trạng thái
      ),
    );
  }
}