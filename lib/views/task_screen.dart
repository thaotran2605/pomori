import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEDE3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.red,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: const Text(
          "Task",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ---------------- BODY ----------------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MONTH + WEEK VIEW
            const SizedBox(height: 10),
            const Text(
              "November 2025",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildWeekCalendar(),

            const SizedBox(height: 20),

            // TASK LIST
            Expanded(
              child: ListView(
                children: const [
                  TaskTile(
                    time: "09:00 AM",
                    title: "Learn UI Design",
                    subtitle: "09:00 AM - 09:50 AM",
                    color: Color(0xFFE65A5A),
                  ),
                  TaskTile(
                    time: "11:00 AM",
                    title: "Reading Books",
                    subtitle: "11:00 AM - 11:50 AM",
                    color: Color(0xFF4CAF50),
                  ),
                  TaskTile(
                    time: "13:00 PM",
                    title: "Editing Video",
                    subtitle: "13:00 PM - 13:50 PM",
                    color: Color(0xFFFFD54F),
                  ),
                  TaskTile(
                    time: "15:00 PM",
                    title: "Editing Video",
                    subtitle: "15:00 PM - 15:50 PM",
                    color: Color(0xFF64B5F6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  // WEEK CALENDAR
  Widget _buildWeekCalendar() {
    final days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isToday = index == 4; // Thứ đang chọn (Th)
        return Column(
          children: [
            Text(days[index],
                style: TextStyle(
                    color: isToday ? Colors.red : Colors.black54)),
            const SizedBox(height: 6),
            CircleAvatar(
              radius: 17,
              backgroundColor: isToday ? Colors.red : Colors.grey.shade300,
              child: Text(
                (2 + index).toString(),
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // BOTTOM NAV BAR
  Widget _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 32), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }
}

// TASK TILE WIDGET
class TaskTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final Color color;

  const TaskTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
