// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
import '../models/bus.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream เพื่อรับข้อมูลป้ายรถเมล์ที่เลือกแบบ Real-time
  Stream<DocumentSnapshot> streamSelectedBusStop(String stopId) {
    return _db.collection('busStops').doc(stopId).snapshots();
  }

  // Stream เพื่อรับข้อมูลป้ายรถเมล์อื่นๆ ในสายเดียวกันแบบ Real-time
  Stream<QuerySnapshot> streamSameLineBusStops(String busLine, String selectedStopId) {
    return _db
        .collection('busStops')
        .where('busLine', isEqualTo: busLine)
        .where(FieldPath.documentId, isNotEqualTo: selectedStopId)
        .snapshots();
  }

  // Stream เพื่อรับข้อมูลรถบัสในสายเดียวกันทั้งหมดแบบ Real-time
  Stream<QuerySnapshot> streamSameLineBuses(String busLine) {
    return _db
        .collection('buses')
        .where('busLine', isEqualTo: busLine)
        .snapshots();
  }
  
  // Method ใหม่: ดึงข้อมูลทั้งหมดของป้ายรถเมล์และรถบัสในสายเดียวกันแบบ One-time
  Future<List<BusStop>> fetchAllBusStops() async {
    final snapshot = await _db.collection('busStops').get();
    return snapshot.docs.map((doc) => BusStop.fromFirestore(doc)).toList();
  }
  
  // Stream เพื่อรับข้อมูลป้ายรถเมล์ทั้งหมดแบบ Real-time (ใช้ใน PassengerDensityScreen)
  Stream<QuerySnapshot> streamAllBusStops() {
    return _db.collection('busStops').snapshots();
  }
  
  // Stream เพื่อรับข้อมูลรถเมล์ทั้งหมดแบบ Real-time (ใช้ใน PassengerDensityScreen)
  Stream<QuerySnapshot> streamAllBuses() {
    return _db.collection('buses').snapshots();
  }

  // *** เมธอดที่ปรับปรุงใหม่เพื่อใช้ใน BusStopBottomSheet ***
  Future<Map<String, dynamic>> fetchSameLineData(String busLine, String selectedStopId) async {
    final List<Future<QuerySnapshot>> futures = [
      _db
          .collection('busStops')
          .where('busLine', isEqualTo: busLine)
          .where(FieldPath.documentId, isEqualTo: selectedStopId)
          .limit(1)
          .get(),
      _db
          .collection('busStops')
          .where('busLine', isEqualTo: busLine)
          .where(FieldPath.documentId, isNotEqualTo: selectedStopId)
          .get(),
      _db
          .collection('buses')
          .where('busLine', isEqualTo: busLine)
          .get(),
    ];

    final results = await Future.wait(futures);
    
    final currentStopDoc = results[0].docs.isNotEmpty ? results[0].docs.first : null;
    final otherStopDocs = results[1].docs;
    final busDocs = results[2].docs;

    final BusStop? currentBusStop = currentStopDoc != null ? BusStop.fromFirestore(currentStopDoc) : null;
    final List<BusStop> sameLineStops = otherStopDocs
        .map((doc) => BusStop.fromFirestore(doc))
        .toList();
    final List<Bus> sameLineBuses = busDocs
        // *** แก้ไขตรงนี้ ***
        .map((doc) => Bus.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();

    return {
      'currentBusStop': currentBusStop,
      'sameLineStops': sameLineStops,
      'sameLineBuses': sameLineBuses,
    };
  }
}