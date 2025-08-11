import 'package:flutter/material.dart';
import '../components/bus_density_card.dart';
import '../mock_data/bus_mock_data.dart';

class PassengerDensityScreen extends StatelessWidget {
  const PassengerDensityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ความหนาแน่นผู้โดยสาร'),
      ),
      body: ListView.builder(
        itemCount: BusMockData.buses.length,
        itemBuilder: (context, index) {
          return BusDensityCard(bus: BusMockData.buses[index]);
        },
      ),
    );
  }
}