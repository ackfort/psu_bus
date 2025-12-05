import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusStop {
  final String stopId;
  final String name;
  final double latitude;
  final double longitude;
  final int passengerCount;
  final String busLine;

  const BusStop({
    required this.stopId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.passengerCount,
    required this.busLine,
  });

  /// Factory constructor สำหรับสร้าง BusStop จาก Firestore Document
  factory BusStop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return BusStop(
      stopId: doc.id,
      name: data['busstop_name'] ?? '', // Firestore field: busstop_name
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      passengerCount:
          (data['people_count'] as num?)?.toInt() ??
          0, // Firestore field: people_count
      busLine: data['bus_line'] ?? 'green', // Firestore field: bus_line
    );
  }

  /// สีของสายรถเมล์
  Color get lineColor {
    switch (busLine) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
      default:
        return Colors.green;
    }
  }

  /// ชื่อสายรถเมล์แบบคนอ่านเข้าใจ
  String get lineName {
    switch (busLine) {
      case 'red':
        return 'สายสีแดง';
      case 'blue':
        return 'สายสีน้ำเงิน';
      case 'green':
      default:
        return 'สายสีเขียว';
    }
  }

  /// สถานะความหนาแน่นของป้าย
  String get status {
    if (passengerCount > 19) return 'หนาแน่นมาก';
    if (passengerCount > 11) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  /// สีบอกความหนาแน่นของป้าย
  Color get statusColor {
    if (passengerCount > 19) return Colors.red;
    if (passengerCount > 11) return Colors.orange;
    return Colors.green;
  }
}
