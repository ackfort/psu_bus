import 'package:flutter/material.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Image.asset(
            'assets/images/PSU-Bus-Routes.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}