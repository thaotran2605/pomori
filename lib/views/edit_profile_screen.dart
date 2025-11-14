import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController =
  TextEditingController(text: "Martin Edwards");
  TextEditingController ageController = TextEditingController(text: "20");

  String gender = "Male";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDEDE3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text("Edit profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage("assets/avatar.jpg"),
            ),
            const SizedBox(height: 10),
            const Text("Chạm để thay đổi ảnh"),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Full name"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: inputDeco(),
                  ),

                  const SizedBox(height: 16),
                  const Text("Age"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: inputDeco(),
                  ),

                  const SizedBox(height: 16),
                  const Text("Gender"),
                  const SizedBox(height: 6),
                  DropdownButtonFormField(
                    value: gender,
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (v) {
                      setState(() => gender = v!);
                    },
                    decoration: inputDeco(),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Save",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }

  InputDecoration inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xffF3E8E5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
