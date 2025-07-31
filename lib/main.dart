import 'package:flutter/material.dart';
import 'components/app_scaffold.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PSU Bus Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1976D2),       // สีฟ้าหลัก
          primaryContainer: const Color(0xFFBBDEFB), // สีฟ้าอ่อนสำหรับ indicator
          onPrimary: Colors.white,                // สีข้อความบนพื้นฟ้า
          surface: Colors.white,                  // สีพื้นหลังหน้าจอ
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,                          // ลบเงา
          centerTitle: true,
        ),
      ),
      home: const AppScaffold(),
    );
  }
}