import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidget = Image.asset(
      'assets/images/pomori_logo.png',
      height: 120,
    );

    final loginLink = GestureDetector(
      onTap: () {
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

    InputDecoration inputStyle(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
              // Logo + tiêu đề
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

              // Full Name
              TextField(
                decoration: inputStyle('Full Name'),
              ),
              const SizedBox(height: 20),

              // ID
              TextField(
                decoration: inputStyle('ID'),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                obscureText: true,
                decoration: inputStyle('Password'),
              ),
              const SizedBox(height: 40),

              // Nút đăng ký
              PrimaryButton(
                text: 'SIGN UP',
                onPressed: () {
                  print('Sign Up Pressed');
                },
              ),
              const SizedBox(height: 20),

              // Chuyển sang Log in
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
