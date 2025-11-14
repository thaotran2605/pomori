import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDEDE3),
      bottomNavigationBar: _buildBottomNav(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Avatar
          const CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage("assets/avatar.jpg"),
          ),

          const SizedBox(height: 12),

          const Text(
            "Martin Edwards",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const Text(
            "martin_edwards@gmail.com",
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 20),

          // Menu items
          menuItem(
            icon: Icons.edit,
            title: "Edit Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),

          menuItem(icon: Icons.notifications, title: "Notifications"),
          menuItem(icon: Icons.lock, title: "Security"),

          menuItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget menuItem(
      {required IconData icon,
        required String title,
        VoidCallback? onTap,
        Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

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
