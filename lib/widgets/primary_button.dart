// lib/widgets/primary_button.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryRed,
        foregroundColor: kInputFillColor, // Chữ màu trắng
        minimumSize: const Size(double.infinity, 60), // Chiều cao cố định
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Bo tròn lớn
        ),
        elevation: 5, // Thêm độ nổi cho nút
        shadowColor: kPrimaryRed.withOpacity(0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}