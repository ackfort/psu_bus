import 'package:flutter/material.dart';

class PassengerDensityScreen extends StatelessWidget {
  const PassengerDensityScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จำนวนผู้ใช้บริการ')),
      body: Center(child: Text('จำนวนผู้ใช้บริการ', style: TextStyle(fontSize: 24))),
    );
  }
}