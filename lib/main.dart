// lib/main.dart
import 'package:flutter/material.dart';
import 'views/new_pomori_screen.dart';
import 'views/login_screen.dart';     // ⬅️ THÊM DÒNG IMPORT NÀY
import 'views/signup_screen.dart';    // ⬅️ THÊM DÒNG IMPORT NÀY
import 'views/timer_screen.dart';    // ⬅️ THÊM DÒNG IMPORT NÀY
import 'views/congrats_screen.dart';    // ⬅️ THÊM DÒNG IMPORT NÀY

// KHAI BÁO MÀU NỀN MỚI BẠN ĐÃ YÊU CẦU TRONG app_constants (CHỈ ĐỊNH Ở ĐÂY NẾU CHƯA CÓ FILE constants)
const Color kPrimaryRed = Color(0xFFF05139);
const Color kLightBackgroundColor = Color(0xFFFDEDE3); // Màu nền mới

void main() async {
  // Lệnh này quan trọng để đảm bảo Flutter khởi tạo đúng cách
  WidgetsFlutterBinding.ensureInitialized();

  // Tạm thời comment phần khởi tạo Firebase (giữ nguyên để không bị lỗi)
  /*
  try {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  } catch (e) {
    print('Firebase initialization skipped: $e');
  }
  */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomori App',
      theme: ThemeData(
        // Thiết lập Theme cơ bản
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: kLightBackgroundColor, // Đặt màu nền mặc định cho Scaffold
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryRed,
          primary: kPrimaryRed,
        ),
        useMaterial3: true,
      ),

      // ⬅️ KHẮC PHỤC LỖI: CHỈ GIỮ LẠI MỘT THUỘC TÍNH 'home'
      // home: const LoginScreen(),
       home: const SignupScreen(),
     // home: const NewPomoriScreen(), // Màn hình bạn muốn kiểm tra
      // home: const TimerScreen(),
      // home: const CongratsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}