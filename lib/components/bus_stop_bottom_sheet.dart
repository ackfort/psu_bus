import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
// ลบการ import mock data ออก
// import '../mock_data/bus_stop_mock_data.dart';

class BusStopBottomSheet extends StatelessWidget {
  final BusStop selectedBusStop;
  final Function() onClose;
  final Function(double, double) onOpenMap;
  final Function(double, double) onOpenDirections;
  // เพิ่ม Stream สำหรับดึงข้อมูลป้ายอื่นในสายเดียวกัน
  final Stream<QuerySnapshot> sameLineStopsStream;

BusStopBottomSheet({ // ลบ const ออก
  super.key,
  required this.selectedBusStop,
  required this.onClose,
  required this.onOpenMap,
  required this.onOpenDirections,
}) : sameLineStopsStream = FirebaseFirestore.instance
          .collection('busStops')
          .where('busLine', isEqualTo: selectedBusStop.busLine)
          .where(FieldPath.documentId, isNotEqualTo: selectedBusStop.stopId)
          .snapshots();

  // ลบ method _getOtherStopsInSameLine() เพราะเราจะใช้ StreamBuilder แทน

  // ฟังก์ชันกำหนดสีตามความหนาแน่นสำหรับแต่ละป้าย
  Color _getStopDensityColor(int passengerCount) {
    if (passengerCount > 25) return Colors.red[600]!;
    if (passengerCount > 15) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  // ฟังก์ชันกำหนดสีพื้นหลังตามความหนาแน่นสำหรับแต่ละป้าย
  Color _getStopDensityBackground(int passengerCount) {
    if (passengerCount > 25) return Colors.red[50]!;
    if (passengerCount > 15) return Colors.orange[50]!;
    return Colors.green[50]!;
  }

  // ฟังก์ชันกำหนดสีตามความหนาแน่นสำหรับทั้งสาย (ตามเกณฑ์ใหม่)
  Color _getLineDensityColor(int totalPassengers) {
    if (totalPassengers >= 200) return Colors.red[600]!;
    if (totalPassengers >= 100) return Colors.amber[600]!;
    return Colors.green[600]!;
  }

  // ฟังก์ชันกำหนดสีพื้นหลังตามความหนาแน่นสำหรับทั้งสาย
  Color _getLineDensityBackground(int totalPassengers) {
    if (totalPassengers >= 200) return Colors.red[50]!;
    if (totalPassengers >= 100) return Colors.amber[50]!;
    return Colors.green[50]!;
  }

  // ฟังก์ชันคำนวณสถานะความหนาแน่นสำหรับทั้งสาย
  String _getLineDensityStatus(int totalPassengers) {
    if (totalPassengers >= 200) return 'หนาแน่นมาก';
    if (totalPassengers >= 100) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = selectedBusStop.lineColor;

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedBusStop.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        selectedBusStop.lineName,
                        style: TextStyle(
                          color: lineColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                  onPressed: onClose,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Passenger information cards
            // ในส่วนของ Row ที่มีป้ายข้อมูล
            Row(
              children: [
                // Current stop card
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.directions_bus,
                    iconColor: _getStopDensityColor(
                      selectedBusStop.passengerCount,
                    ), // เปลี่ยนจาก lineColor เป็นสีตามความหนาแน่น
                    title: 'ป้ายนี้',
                    value: '${selectedBusStop.passengerCount} คน',
                    status: selectedBusStop.status,
                    backgroundColor: _getStopDensityBackground(
                      selectedBusStop.passengerCount,
                    ),
                    valueColor: _getStopDensityColor(
                      selectedBusStop.passengerCount,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Total line card - ใช้ StreamBuilder เพื่อคำนวณแบบ real-time
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: sameLineStopsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _buildInfoCard(
                          icon: Icons.error_outline,
                          iconColor: Colors.grey,
                          title: 'รวมทั้งสาย',
                          value: 'Error',
                          status: 'เกิดข้อผิดพลาด',
                          backgroundColor: Colors.grey[100]!,
                          valueColor: Colors.grey,
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildInfoCard(
                          icon: Icons.alt_route,
                          iconColor: Colors.grey,
                          title: 'รวมทั้งสาย',
                          value: 'Loading...',
                          status: 'กำลังโหลด',
                          backgroundColor: Colors.grey[100]!,
                          valueColor: Colors.grey,
                        );
                      }

                      // คำนวณจำนวนผู้โดยสารรวม
                      int totalPassengers = selectedBusStop.passengerCount;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final stop = BusStop.fromFirestore(doc);
                          totalPassengers += stop.passengerCount;
                        }
                      }

                      return _buildInfoCard(
                        icon: Icons.alt_route,
                        iconColor: _getLineDensityColor(totalPassengers),
                        title: 'รวมทั้งสาย',
                        value: '$totalPassengers คน',
                        status: _getLineDensityStatus(totalPassengers),
                        backgroundColor: _getLineDensityBackground(totalPassengers),
                        valueColor: _getLineDensityColor(totalPassengers),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Other stops section - ใช้ StreamBuilder สำหรับป้ายอื่นในสาย
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: sameLineStopsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final sameLineStops = snapshot.data!.docs
                    .map((doc) => BusStop.fromFirestore(doc))
                    .toList();

                if (sameLineStops.isEmpty) {
                  return SizedBox(); // ไม่แสดงส่วนนี้ถ้าไม่มีป้ายอื่น
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.list, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'ป้ายอื่นในสายนี้',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          // Legend
                          Row(
                            children: [
                              _buildDensityLegendItem('น้อย', Colors.green),
                              const SizedBox(width: 8),
                              _buildDensityLegendItem('ปานกลาง', Colors.amber),
                              const SizedBox(width: 8),
                              _buildDensityLegendItem('มาก', Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: sameLineStops.length,
                          itemBuilder: (context, index) {
                            final stop = sameLineStops[index];
                            final densityColor = _getStopDensityColor(
                              stop.passengerCount,
                            );
                            return Container(
                              decoration: BoxDecoration(
                                color: index.isOdd ? Colors.grey.shade50 : Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stop.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStopDensityBackground(
                                          stop.passengerCount,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: densityColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: densityColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${stop.passengerCount} คน',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: densityColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.map_outlined, size: 20, color: lineColor),
                    label: Text(
                      'ดูบนแผนที่',
                      style: TextStyle(
                        color: lineColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed:
                        () => onOpenMap(
                          selectedBusStop.latitude,
                          selectedBusStop.longitude,
                        ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: lineColor,
                      side: BorderSide(color: lineColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.directions, size: 20, color: Colors.white),
                    label: Text(
                      'นำทาง',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed:
                        () => onOpenDirections(
                          selectedBusStop.latitude,
                          selectedBusStop.longitude,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lineColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: lineColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensityLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String status,
    required Color backgroundColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}