import 'package:flutter/material.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เส้นทางเดินรถประจำทาง')),
      body: Center(child: Text('เส้นทางเดินรถประจำทาง', style: TextStyle(fontSize: 24))),
    );
  }
}