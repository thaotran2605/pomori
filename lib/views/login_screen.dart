// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart'; // Để chuyển sang màn hình Đăng ký

// lib/views/login_screen.dart (hoặc vị trí hiện tại của bạn)

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... Khai báo logoWidget và các style khác ...
    final logoWidget = Image.asset(
      'assets/images/pomori_logo.png',
      height: 120,
    );

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: SafeArea(
        // THAY THẾ SingleChildScrollView BẰNG CustomScrollView
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              // Đặt hasScrollBody: false nếu bạn không muốn cuộn khi không cần thiết
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  // ĐÂY LÀ ĐIỂM QUAN TRỌNG: Column SẼ ĐƯỢC CĂN GIỮA TRONG KHÔNG GIAN CÒN LẠI
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    logoWidget,
                    const SizedBox(height: 16),
                    // ... Các widget còn lại ...
                    const Text(
                      'Pomori',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryRed,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Form Đăng nhập
                    const CustomTextField(hintText: 'ID'),
                    const SizedBox(height: 20),
                    const CustomTextField(hintText: 'Password', isPassword: true),
                    const SizedBox(height: 40),

                    // Nút Đăng nhập
                    PrimaryButton(
                      text: 'LOG IN',
                      onPressed: () {
                        print('Login Pressed');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Nút Chuyển sang Đăng ký
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryRed,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}