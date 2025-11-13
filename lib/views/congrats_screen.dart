import 'package:flutter/material.dart';

// Giả định bottom_nav_bar.dart ở trong views/widgets/
import '../widgets/bottom_nav_bar.dart';

class CongratsScreen extends StatelessWidget {
  const CongratsScreen({super.key});

  static void _handleNavigationTap(int index) {
    print('Navigating from Congrats to tab $index');
  }

  // Khai báo đường dẫn đến hình ảnh mới của bạn
  final String _congratsImagePath = 'assets/images/trophy.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDECEB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pomori Timer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_horiz, color: Colors.black),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
// --- 1. Thay thế Cúp và Pháo hoa bằng Image.asset ---
              SizedBox(
                width: 200,
                height: 200,
                // Thay thế Stack bằng Image.asset
                child: Image.asset(
                  _congratsImagePath, // Đường dẫn đến hình ảnh tùy chỉnh của bạn
                  fit: BoxFit.contain, // Đảm bảo hình ảnh vừa vặn trong hộp
                  // Bạn có thể thêm color hoặc colorBlendMode nếu hình ảnh là SVG hoặc cần tô màu
                ),
              ),
              const SizedBox(height: 50),

// --- 2. Congratulatory Text ---
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF75F5C), // Màu đỏ/hồng tươi
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your task is completed',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0, // Vẫn là tab Home/Timer
        onTap: _handleNavigationTap,
      ),
    );
  }
}

// Không cần dùng _CelebrationParticle nữa, có thể xóa nếu không dùng ở đâu khác.
/*
class _CelebrationParticle extends StatelessWidget {
  // ... (Phần mã này không còn cần thiết) ...
}
*/