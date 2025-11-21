// File: views/main_app_layout_view.dart

import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'new_pomori_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class MainAppLayoutView extends StatefulWidget {
  const MainAppLayoutView({super.key});

  static const routeName = '/main';

  @override
  State<MainAppLayoutView> createState() => _MainAppLayoutViewState();
}

class _MainAppLayoutViewState extends State<MainAppLayoutView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const NewPomoriScreen(),
    const StatsScreen(),
    const ProfileScreen(),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
