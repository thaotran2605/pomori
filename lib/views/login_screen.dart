import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logoWidget = Image.asset(
      'assets/images/pomori_logo.png',
      height: 120,
    );

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
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

                    // ID
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ID',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login button
                    PrimaryButton(
                      text: 'LOG IN',
                      onPressed: () {
                        print('Login Pressed');
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sign up link
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
