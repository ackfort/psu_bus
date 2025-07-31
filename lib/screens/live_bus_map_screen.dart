import 'package:flutter/material.dart';

class LiveBusMapScreen extends StatelessWidget {
  const LiveBusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แผนที่')),
      body: Center(child: Text('แผนที่', style: TextStyle(fontSize: 24))),
    );
  }
}
