import 'package:flutter/material.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  int sessionCount = 3;
  int focusTime = 25;
  int breakTime = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEDE3), // Nền hồng nhạt
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HEADER ----
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "New Task",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ---- FORM BOX ----
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- TASK NAME ----
                    const Text(
                      "Task name",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "e.g. Study Math",
                        filled: true,
                        fillColor: const Color(0xFFF5EFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- DATE + START TIME ----
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Date",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              _pickerField(Icons.calendar_month, "Date"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Start time",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              _pickerField(Icons.access_time, "Start Time"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---- SESSION ----
                    const Text(
                      "Session",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _roundButton(Icons.remove, () {
                          setState(() {
                            if (sessionCount > 1) sessionCount--;
                          });
                        }),
                        Expanded(
                          child: Center(
                            child: Text(
                              "$sessionCount",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        _roundButton(Icons.add, () {
                          setState(() {
                            sessionCount++;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---- FOCUS TIME + BREAK TIME ----
                    Row(
                      children: [
                        _timeBox("Focus time", "$focusTime minutes"),
                        const SizedBox(width: 12),
                        _timeBox("Break time", "$breakTime minutes"),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ---- BUTTON ----
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F6F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Create New Task",
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- WIDGETS ----

  Widget _pickerField(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _timeBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
}
