// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart'; // Để chuyển sang màn hình Đăng nhập

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidget = Image.asset(
      'assets/images/pomori_logo.png', // Tự tạo file này trong thư mục assets
      height: 120,
    );

    // Nút Log In nhỏ
    final loginLink = GestureDetector(
      onTap: () {
        // Quay lại màn hình đăng nhập (hoặc dùng pop)
        Navigator.of(context).pop();
      },
      child: const Text(
        'Log in',
        style: TextStyle(
          fontSize: 16,
          color: kPrimaryRed,
          decoration: TextDecoration.underline,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo và Tên
              logoWidget,
              const SizedBox(height: 16),
              const Text(
                'Pomori',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryRed,
                ),
              ),
              const SizedBox(height: 60),

              // Form Đăng ký
              const CustomTextField(hintText: 'Full Name'),
              const SizedBox(height: 20),
              const CustomTextField(hintText: 'ID'),
              const SizedBox(height: 20),
              const CustomTextField(hintText: 'Password', isPassword: true),
              const SizedBox(height: 40),

              // Nút Đăng ký
              PrimaryButton(
                text: 'SIGN UP',
                onPressed: () {
                  // TODO: Gọi API Đăng ký
                  print('Sign Up Pressed');
                },
              ),
              const SizedBox(height: 20),

              // Chuyển sang Đăng nhập
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: kTextColor.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  loginLink,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}