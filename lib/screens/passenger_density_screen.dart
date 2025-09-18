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

  // No longer need _loadBusStops() method or busStops list
  // The StreamBuilder will handle the data stream.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter section remains the same
          DensityFilterSection(
            selectedLine: selectedLine,
            onLineChanged: (newLine) => setState(() => selectedLine = newLine),
            showBuses: false,
            onBusesChanged: (_) {},
            showBusStops: showBusStops,
            onBusStopsChanged: (selected) => setState(() => showBusStops = selected),
          ),

          // Use StreamBuilder to listen for real-time updates
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('busStops').snapshots(),
              builder: (context, snapshot) {
                // Handle error state
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                  );
                }

                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Convert snapshot to a list of BusStop objects
                final allBusStops = snapshot.data!.docs
                    .map((doc) => BusStop.fromFirestore(doc))
                    .toList();

                // Apply the filter
                final filteredBusStops = allBusStops
                    .where((stop) =>
                        selectedLine == 'ทั้งหมด' ||
                        stop.lineName == selectedLine)
                    .toList();

                // Display the filtered data
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (showBusStops) ...[
                        _buildSectionHeader('ป้ายรถเมล์ทั้งหมด', filteredBusStops.length),
                        ...filteredBusStops
                            .map((stop) => BusStopDensityCard(busStop: stop))
                            .toList(),
                        const SizedBox(height: 16),
                      ],
                      if (filteredBusStops.isEmpty && showBusStops)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'ไม่พบป้ายรถเมล์ในสายนี้',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Adjusted _buildSectionHeader to accept a count
  Widget _buildSectionHeader(String title, int count) {
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
            '$count รายการ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}