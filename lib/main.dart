import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/notification_service.dart';
import 'services/bus_data_monitor.dart';

import 'components/app_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(); 
  
  await NotificationService().initializeNotifications();
  
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
          primary: const Color(0xFF1976D2),
          primaryContainer: const Color(0xFFBBDEFB),
          onPrimary: Colors.white,
          surface: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AppScaffold(),
    );
  }
}