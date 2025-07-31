import 'package:flutter/material.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        panEnabled: true, // อนุญาตให้เลื่อนภาพ
        minScale: 0.5, // ซูมออกได้น้อยสุด 50%
        maxScale: 3.0, // ซูมเข้าได้มากสุด 300%
        child: Center(
          child: Image.asset(
            'assets/images/PSU-Bus-Routes.jpg', // เปลี่ยนเป็น path รูปของคุณ
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
