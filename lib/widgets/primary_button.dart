// lib/widgets/primary_button.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
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
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(kInputFillColor),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
