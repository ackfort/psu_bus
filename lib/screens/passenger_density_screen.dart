//passenger_density_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
import '../models/bus.dart';
import '../components/bus_stop_density_card.dart'; // ยังต้องใช้สำหรับ BusStop
import '../components/bus_density_card.dart'; // **เพิ่ม import ใหม่สำหรับ BusDensityCard**
import '../components/density_filter_section.dart';
import 'package:collection/collection.dart';

class PassengerDensityScreen extends StatefulWidget {
  const PassengerDensityScreen({super.key});

  @override
  State<PassengerDensityScreen> createState() => _PassengerDensityScreenState();
}

class _PassengerDensityScreenState extends State<PassengerDensityScreen> {
  String selectedLine = 'ทั้งหมด';
  bool showBusStops = true;
  bool showBuses = true;

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
            showBuses: showBuses,
            onBusesChanged: (selected) => setState(() => showBuses = selected),
            showBusStops: showBusStops,
            onBusStopsChanged: (selected) => setState(() => showBusStops = selected),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // StreamBuilder สำหรับแสดงข้อมูลป้ายรถเมล์ (Bus Stops)
                  if (showBusStops)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('busStops').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingIndicator();
                        }
                        if (snapshot.hasError) {
                          return _buildErrorText();
                        }

                        final allBusStops = snapshot.data!.docs
                            .map((doc) => BusStop.fromFirestore(doc))
                            .toList();
                        final filteredBusStops = allBusStops
                            .where((stop) =>
                                selectedLine == 'ทั้งหมด' ||
                                stop.lineName == selectedLine)
                            .toList();

                        return Column(
                          children: [
                            _buildSectionHeader('ป้ายรถเมล์', filteredBusStops.length),
                            if (filteredBusStops.isEmpty)
                              _buildNoDataText('ไม่พบป้ายรถเมล์ในสายนี้'),
                            ...filteredBusStops
                                .map((stop) => BusStopDensityCard(busStop: stop))
                                .toList(),
                          ],
                        );
                      },
                    ),

                  // StreamBuilder สำหรับแสดงข้อมูลรถเมล์ (Buses)
                  if (showBuses)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('buses').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingIndicator();
                        }
                        if (snapshot.hasError) {
                          return _buildErrorText();
                        }

                        final allBuses = snapshot.data!.docs
                            .map((doc) => Bus.fromFirestore(doc.data() as Map<String, dynamic>))
                            .toList();
                        final filteredBuses = allBuses
                            .where((bus) =>
                                selectedLine == 'ทั้งหมด' ||
                                bus.lineName == selectedLine)
                            .toList();

                        final groupedBuses = groupBy(filteredBuses, (bus) => bus.busLine);

                        return Column(
                          children: [
                            _buildSectionHeader('รถเมล์', filteredBuses.length),
                            if (filteredBuses.isEmpty)
                              _buildNoDataText('ไม่พบรถเมล์ในสายนี้'),
                            ...groupedBuses.entries.expand((entry) {
                              final lineName = entry.value.first.lineName;
                              final lineColor = entry.value.first.lineColor;
                              return [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: lineColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lineName,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // **เรียกใช้ BusDensityCard แทน BusStopDensityCard**
                                ...entry.value.map((bus) => BusDensityCard(bus: bus)).toList(),
                              ];
                            }).toList(),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorText() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Text(
          'เกิดข้อผิดพลาดในการโหลดข้อมูล',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNoDataText(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}