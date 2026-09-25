// จุดเริ่มต้นของแอป
// หัวข้อ 2: Basic Flutter Components + หัวข้อ 7: Navigation and Routing
// - เชื่อม Firebase ตอนเปิดแอป (หัวข้อ 11)
// - ใช้ StreamBuilder ฟัง authStateChanges เพื่อสลับหน้า Login <-> Home อัตโนมัติ

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // ไฟล์นี้สร้างอัตโนมัติด้วยคำสั่ง `flutterfire configure`
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  // ต้องเรียกก่อนใช้ปลั๊กอินใด ๆ ที่ต้องคุยกับ native platform
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CanteenBookingApp());
}

class CanteenBookingApp extends StatelessWidget {
  const CanteenBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'จองโต๊ะโรงอาหาร',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      // ไม่ใช้ named routes แบบตายตัว เพราะหน้าแรกขึ้นกับสถานะ login
      // ถ้าต้องการทำ named routes เพิ่มเติม (เช่นหน้า detail) ให้ใส่ใน `routes: {}` ตรงนี้ได้
      home: const _AuthGate(),
    );
  }
}

// widget ตัวกลาง คอยเช็คว่า "ล็อกอินอยู่ไหม" แล้วเลือกหน้าที่จะแสดงให้ถูกต้อง
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
