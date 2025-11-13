// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kInputFillColor,
        borderRadius: BorderRadius.circular(15), // Góc bo tròn nhẹ
        boxShadow: [
          // Shadow mờ để nổi bật ô nhập liệu
          BoxShadow(
            color: kTextColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Ẩn chữ nếu là mật khẩu
        style: const TextStyle(color: kTextColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: kTextColor.withOpacity(0.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),

          // Loại bỏ đường viền mặc định
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}