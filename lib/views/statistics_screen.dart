import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedRange = "This week";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDEDE3),
      bottomNavigationBar: _buildBottomNav(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Statistics", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Statistics Graph",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Dropdown
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(
                value: selectedRange,
                items: const [
                  DropdownMenuItem(value: "This week", child: Text("This week")),
                  DropdownMenuItem(value: "This month", child: Text("This month")),
                ],
                onChanged: (value) {
                  setState(() => selectedRange = value!);
                },
              ),
            ),

            const SizedBox(height: 10),

            // GRAPH
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitleWidgets),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.red,
                      spots: const [
                        FlSpot(0, 7),
                        FlSpot(1, 3),
                        FlSpot(2, 4),
                        FlSpot(3, 6),
                        FlSpot(4, 5),
                        FlSpot(5, 8),
                        FlSpot(6, 7),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Today, November 6",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 16),

            // Activity items
            taskItem(
              icon: Icons.menu_book_rounded,
              color: Colors.yellow.shade700,
              title: "Reading Books",
              minutes: 50,
              timeRange: "9:00 AM - 9:50 AM",
            ),

            taskItem(
              icon: Icons.music_note_rounded,
              color: Colors.orange,
              title: "Editing Audio",
              minutes: 75,
              timeRange: "11:00 AM - 12:15 PM",
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom navigation bar
  // ---- BOTTOM NAV ----
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home, size: 26),
          Icon(Icons.list_alt, size: 26),
          Icon(Icons.add_circle, size: 36, color: Colors.red),
          Icon(Icons.bar_chart, size: 26),
          Icon(Icons.person, size: 26),
        ],
      ),
    );
  }

  /// Bottom labels for graph
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12, color: Colors.black87);
    switch (value.toInt()) {
      case 0:
        return const Text("Mon", style: style);
      case 1:
        return const Text("Tue", style: style);
      case 2:
        return const Text("Wed", style: style);
      case 3:
        return const Text("Thu", style: style);
      case 4:
        return const Text("Fri", style: style);
      case 5:
        return const Text("Sat", style: style);
      case 6:
        return const Text("Sun", style: style);
    }
    return const Text("");
  }

  /// Activity UI box
  Widget taskItem({
    required IconData icon,
    required Color color,
    required String title,
    required int minutes,
    required String timeRange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF9ECE7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text("$minutes minutes",
                  style: const TextStyle(color: Colors.black54)),
              Text(timeRange, style: const TextStyle(color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }
}
