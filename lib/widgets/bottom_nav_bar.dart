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
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: _buildCenterActionIcon(isActive: false),
          activeIcon: _buildCenterActionIcon(isActive: true),
          label: 'New',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_sharp),
          label: 'Stats',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1B1B1B),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.white,
      elevation: 12,
    );
  }

  static Widget _buildCenterActionIcon({required bool isActive}) {
    const primaryColor = Color(0xFFF75F5C);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.add,
        color: isActive ? Colors.white : primaryColor,
        size: 26,
      ),
    );
  }
}
