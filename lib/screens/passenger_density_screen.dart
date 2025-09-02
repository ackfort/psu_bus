import 'package:flutter/material.dart';
import 'package:psu_bus/models/bus.dart';
import 'package:psu_bus/models/bus_stop.dart';
import '../components/bus_density_card.dart';
import '../components/bus_stop_density_card.dart';
import '../components/density_filter_section.dart'; // นำเข้า Component ใหม่
import '../mock_data/bus_mock_data.dart';
import '../mock_data/bus_stop_mock_data.dart';

class PassengerDensityScreen extends StatefulWidget {
  const PassengerDensityScreen({super.key});

  @override
  State<PassengerDensityScreen> createState() => _PassengerDensityScreenState();
}

class _PassengerDensityScreenState extends State<PassengerDensityScreen> {
  String selectedLine = 'ทั้งหมด';
  bool showBuses = true;
  bool showBusStops = true;

  List<Bus> get filteredBuses {
    if (selectedLine == 'ทั้งหมด') return BusMockData.buses;
    return BusMockData.buses.where((bus) => bus.lineName == selectedLine).toList();
  }

  List<BusStop> get filteredBusStops {
    if (selectedLine == 'ทั้งหมด') return BusStopMockData.busStops;
    return BusStopMockData.busStops.where((stop) => stop.lineName == selectedLine).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ใช้ DensityFilterSection แทน
          DensityFilterSection(
            selectedLine: selectedLine,
            onLineChanged: (newLine) => setState(() => selectedLine = newLine),
            showBuses: showBuses,
            onBusesChanged: (selected) => setState(() => showBuses = selected),
            showBusStops: showBusStops,
            onBusStopsChanged: (selected) => setState(() => showBusStops = selected),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (showBuses) ...[
                    _buildSectionHeader('รถเมล์ทั้งหมด'),
                    ...filteredBuses.map((bus) => BusDensityCard(bus: bus)).toList(),
                  ],
                  
                  if (showBusStops) ...[
                    _buildSectionHeader('ป้ายรถเมล์ทั้งหมด'),
                    ...filteredBusStops.map((stop) => BusStopDensityCard(busStop: stop)).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${title.contains('รถเมล์') ? filteredBuses.length : filteredBusStops.length} รายการ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}