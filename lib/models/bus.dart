import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bus {
  final String busId;
  final String busName;
  final double latitude;
  final double longitude;
  final int passengerCount;
  final String busLine; // 'green', 'red', 'blue'

  const Bus({
    required this.busId,
    required this.busName,
    required this.latitude,
    required this.longitude,
    required this.passengerCount,
    required this.busLine,
  });

  factory Bus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Bus(
      busId: doc.id,
      busName: data['bus_name'] ?? '', // เปลี่ยนจาก 'busName' -> 'bus_name'
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      passengerCount:
          (data['people_count'] as num?)?.toInt() ??
          0, // เปลี่ยนจาก 'passengerCount' -> 'people_count'
      busLine:
          data['bus_line'] ?? 'green', // เปลี่ยนจาก 'busLine' -> 'bus_line'
    );
  }

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

  String get status {
    if (passengerCount > 19) return 'หนาแน่นมาก';
    if (passengerCount > 11) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  Color get statusColor {
    if (passengerCount > 19) return Colors.red;
    if (passengerCount > 11) return Colors.orange;
    return Colors.green;
  }
}
