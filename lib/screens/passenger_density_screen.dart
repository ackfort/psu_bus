import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
import '../components/bus_stop_density_card.dart';
import '../components/density_filter_section.dart';

class PassengerDensityScreen extends StatefulWidget {
  const PassengerDensityScreen({super.key});

  @override
  State<PassengerDensityScreen> createState() => _PassengerDensityScreenState();
}

class _PassengerDensityScreenState extends State<PassengerDensityScreen> {
  String selectedLine = 'ทั้งหมด';
  bool showBusStops = true;

  List<BusStop> busStops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusStops();
  }

  Future<void> _loadBusStops() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('busStops').get();

      busStops = snapshot.docs.map((doc) => BusStop.fromFirestore(doc)).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("โหลดข้อมูลป้ายรถเมล์ล้มเหลว: $e");
      setState(() => _isLoading = false);
    }
  }

  List<BusStop> get filteredBusStops {
    if (selectedLine == 'ทั้งหมด') return busStops;
    return busStops.where((stop) => stop.lineName == selectedLine).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ส่วน filter
          DensityFilterSection(
            selectedLine: selectedLine,
            onLineChanged: (newLine) => setState(() => selectedLine = newLine),
            showBuses: false, // ปิด bus
            onBusesChanged: (_) {},
            showBusStops: showBusStops,
            onBusStopsChanged: (selected) => setState(() => showBusStops = selected),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (showBusStops) ...[
                          _buildSectionHeader('ป้ายรถเมล์ทั้งหมด'),
                          ...filteredBusStops
                              .map((stop) => BusStopDensityCard(busStop: stop))
                              .toList(),
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
            '${filteredBusStops.length} รายการ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}