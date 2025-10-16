// bus_data_monitor.dart (ฉบับแก้ไขใช้ Persistent State)

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< เพิ่ม
import '../models/bus.dart';
import '../models/bus_stop.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

// เกณฑ์ความหนาแน่นที่เรากำหนดไว้
const int _CROWD_THRESHOLD = 19;

class BusDataMonitor {
  // Singleton Pattern
  BusDataMonitor._internal();
  static final BusDataMonitor _instance = BusDataMonitor._internal();
  factory BusDataMonitor() => _instance;

  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  // ตัวแปรสำหรับเก็บ Subscription
  StreamSubscription<QuerySnapshot>? _busSubscription;
  StreamSubscription<QuerySnapshot>? _busStopSubscription;
  
  // 💡 ตัวแปร SharedPreferences และ Keys สำหรับเก็บสถานะถาวร
  late final SharedPreferences _prefs;
  static const String _KEY_CROWDED_BUSES = 'crowdedBusIds';
  static const String _KEY_CROWDED_STOPS = 'crowdedStopIds';

  // เมธอดสำหรับโหลดสถานะ SharedPreferences
  Future<void> _loadPersistentState() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Helper: โหลด Set ของ ID ที่คนแน่นจาก SharedPreferences
  Set<String> _getCrowdedIds(String key) {
    return _prefs.getStringList(key)?.toSet() ?? {};
  }

  // Helper: บันทึก Set ของ ID ที่คนแน่นไปยัง SharedPreferences
  Future<void> _saveCrowdedIds(String key, Set<String> ids) async {
    await _prefs.setStringList(key, ids.toList());
  }


  // 1. ฟังก์ชันหลักสำหรับเริ่มการเฝ้าดูข้อมูลทั้งหมด
  void startMonitoring() async {
    // ต้องโหลดสถานะถาวรก่อน จึงจะเริ่มฟัง Stream ได้
    await _loadPersistentState(); // <<< ต้องรอตรงนี้

    stopMonitoring(); // หยุดการฟังเก่าก่อน หากมีการเรียกใช้ซ้ำ

    // เริ่มฟัง Stream ข้อมูลรถบัสทั้งหมด
    _busSubscription = _firestoreService.streamAllBuses().listen(
      _handleBusUpdates,
      onError: (error) => print('Bus Stream Error: $error'),
    );

    // เริ่มฟัง Stream ข้อมูลป้ายรถเมล์ทั้งหมด
    _busStopSubscription = _firestoreService.streamAllBusStops().listen(
      _handleBusStopUpdates,
      onError: (error) => print('Bus Stop Stream Error: $error'),
    );
  }

  // 2. ฟังก์ชันจัดการการอัปเดตข้อมูลรถบัส
  void _handleBusUpdates(QuerySnapshot snapshot) {
    // โหลดสถานะล่าสุดจาก SharedPreferences
    Set<String> crowdedBuses = _getCrowdedIds(_KEY_CROWDED_BUSES);
    bool stateChanged = false; // Flag สำหรับตรวจสอบว่า Set มีการเปลี่ยนแปลงหรือไม่

    for (var doc in snapshot.docs) {
      final Bus bus = Bus.fromFirestore(doc.data() as Map<String, dynamic>);
      final String busId = bus.busId; 

      if (bus.passengerCount > _CROWD_THRESHOLD) {
        
        // 💡 Edge Triggering: หากคนแน่น และยังไม่เคยแจ้งเตือนมาก่อน
        if (!crowdedBuses.contains(busId)) {
          _notificationService.showCrowdAlertForBus(bus);
          crowdedBuses.add(busId); // เพิ่มใน Set 
          stateChanged = true;
        }
        
      } else {
        // คนไม่แน่นแล้ว (กลับสู่สภาวะปกติ)
        
        // 💡 Edge Triggering: หากเคยแจ้งเตือน แต่ตอนนี้กลับมาปกติแล้ว
        if (crowdedBuses.contains(busId)) {
          _notificationService.cancelNotificationById(busId.hashCode);
          crowdedBuses.remove(busId); // ลบออกจาก Set
          stateChanged = true;
        }
      }
    }
    
    // บันทึกสถานะกลับคืนไปที่ SharedPreferences ถ้ามีการเปลี่ยนแปลง
    if (stateChanged) {
      _saveCrowdedIds(_KEY_CROWDED_BUSES, crowdedBuses);
    }
  }

  // 3. ฟังก์ชันจัดการการอัปเดตข้อมูลป้ายรถเมล์
  void _handleBusStopUpdates(QuerySnapshot snapshot) {
    // โหลดสถานะล่าสุดจาก SharedPreferences
    Set<String> crowdedStops = _getCrowdedIds(_KEY_CROWDED_STOPS);
    bool stateChanged = false;

    for (var doc in snapshot.docs) {
      final BusStop busStop = BusStop.fromFirestore(doc);
      final String stopId = busStop.stopId; 

      if (busStop.passengerCount > _CROWD_THRESHOLD) {
        
        // 💡 Edge Triggering: หากคนแน่น และยังไม่เคยแจ้งเตือนมาก่อน
        if (!crowdedStops.contains(stopId)) {
          _notificationService.showCrowdAlertForStop(busStop);
          crowdedStops.add(stopId); // เพิ่มใน Set
          stateChanged = true;
        }
        
      } else {
        // คนไม่แน่นแล้ว (กลับสู่สภาวะปกติ)
        
        // 💡 Edge Triggering: หากเคยแจ้งเตือน แต่ตอนนี้กลับมาปกติแล้ว
        if (crowdedStops.contains(stopId)) {
          _notificationService.cancelNotificationById(stopId.hashCode);
          crowdedStops.remove(stopId); // ลบออกจาก Set
          stateChanged = true;
        }
      }
    }
    
    // บันทึกสถานะกลับคืนไปที่ SharedPreferences ถ้ามีการเปลี่ยนแปลง
    if (stateChanged) {
      _saveCrowdedIds(_KEY_CROWDED_STOPS, crowdedStops);
    }
  }

  // 4. ฟังก์ชันสำหรับหยุดการเฝ้าดู
  void stopMonitoring() {
    _busSubscription?.cancel();
    _busStopSubscription?.cancel();
  }
}