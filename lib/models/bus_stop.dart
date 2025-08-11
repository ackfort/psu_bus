import 'package:flutter/material.dart';

class BusStop {
  final String stopId;
  final String name;
  final double latitude;
  final double longitude;
  final int passengerCount;
  final String busLine; // 'green', 'red', 'blue'

  const BusStop({
    required this.stopId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.passengerCount,
    required this.busLine,
  });

  // ตัวช่วยสำหรับแปลงจาก Firestore
  factory BusStop.fromFirestore(Map<String, dynamic> data) {
    return BusStop(
      stopId: data['stop_id'] ?? '',
      name: data['name'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      passengerCount: data['current_passengers'] ?? 0,
      busLine: data['bus_line'] ?? 'green',
    );
  }

  // สีของสายรถตาม busLine
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

  // ชื่อสายรถแบบเต็ม
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

  // คำนวณสถานะความหนาแน่น
  String get status {
    if (passengerCount > 25) return 'หนาแน่นมาก';
    if (passengerCount > 15) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  // สีสถานะตามจำนวนผู้โดยสาร
  Color get statusColor {
    if (passengerCount > 25) return Colors.red;
    if (passengerCount > 15) return Colors.orange;
    return Colors.green;
  }
}