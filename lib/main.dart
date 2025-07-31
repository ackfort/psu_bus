import 'package:flutter/material.dart';
import 'components/app_scaffold.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(useMaterial3: true),
      home: const AppScaffold(), // ใช้ Scaffold หลักที่นี่
      debugShowCheckedModeBanner: false,
    );
  }
}