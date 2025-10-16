//main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // สำหรับ Firebase

// **Import Service ที่สร้างขึ้นมา**
import 'services/notification_service.dart';
import 'services/bus_data_monitor.dart';

import 'components/app_scaffold.dart';

Future<void> main() async {
  // 1. ตรวจสอบให้แน่ใจว่า Widgets ถูก Initialize ก่อนการเรียกใช้ Plugin ใดๆ
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase
  await Firebase.initializeApp(); 
  
  // 3. Initialize Notification Service (ตั้งค่าระบบ Notification และขอสิทธิ์)
  // ต้องเรียกใช้ก่อนที่จะเริ่ม Monitor ข้อมูล
  await NotificationService().initializeNotifications();
  
  // 4. เริ่ม Data Monitoring (เริ่มฟัง Stream ข้อมูลจาก Firebase และตรวจสอบเงื่อนไขความหนาแน่น)
  BusDataMonitor().startMonitoring(); 
  
  runApp(const MyApp());
}

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
          onPrimary: Colors.white,               // สีข้อความบนพื้นฟ้า
          surface: Colors.white,                 // สีพื้นหลังหน้าจอ
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,                         // ลบเงา
          centerTitle: true,
        ),
      ),
      home: const AppScaffold(),
    );
  }
}