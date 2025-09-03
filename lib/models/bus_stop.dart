import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// ✅ ตัวช่วยสำหรับแปลงจาก Firestore Document
  factory BusStop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return BusStop(
      stopId: doc.id, // ใช้ documentId ของ Firestore เป็น stopId
      name: data['name'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      passengerCount:
          (data['passengerCount'] as num?)?.toInt() ??
          0, // เปลี่ยนเป็น passengerCount
      busLine: data['busLine'] ?? 'green', // เปลี่ยนเป็น busLine
    );
  }

  // 🔹 สีของสายรถตาม busLine
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

  // 🔹 ชื่อสายรถแบบเต็ม
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

  // 🔹 คำนวณสถานะความหนาแน่น
  String get status {
    if (passengerCount > 25) return 'หนาแน่นมาก';
    if (passengerCount > 15) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  // 🔹 สีสถานะตามจำนวนผู้โดยสาร
  Color get statusColor {
    if (passengerCount > 25) return Colors.red;
    if (passengerCount > 15) return Colors.orange;
    return Colors.green;
  }
}
