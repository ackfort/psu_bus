// notification_service.dart (ฉบับแก้ไขข้อความ)

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ต้อง import Model ของคุณมาด้วย
import '../models/bus.dart'; 
import '../models/bus_stop.dart';

// สร้างอินสแตนซ์หลักของ Notification Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  // Constants สำหรับ Notification Channel
  static const String _crowdChannelId = 'psu_bus_crowd_alert';
  static const String _crowdChannelName = 'แจ้งเตือนความหนาแน่น';
  static const String _crowdChannelDescription = 
      'แจ้งเตือนเมื่อจำนวนผู้โดยสารบนรถหรือที่ป้ายเกินเกณฑ์ที่กำหนด (19 คน)';
  
  // Singleton Pattern: เพื่อให้มั่นใจว่ามี Service Instance เดียว
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  // ฟังก์ชันสำหรับตั้งค่าเริ่มต้น Notification และขอสิทธิ์
  Future<void> initializeNotifications() async {
    // 1. ตั้งค่าสำหรับ Android โดยใช้ไอคอนหลักของแอปฯ
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. ตั้งค่ารวม
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // 3. เริ่มต้น Plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // สามารถใช้ notificationResponse.payload เพื่อแยกแยะว่าผู้ใช้แตะ Noti ประเภทใด
        debugPrint('Notification Payload: ${notificationResponse.payload}');
      },
    );

    // 4. ขอสิทธิ์แจ้งเตือนทันที (สำหรับ Android 13 / API 33 ขึ้นไป)
    _requestPermissions();
  }

  // ฟังก์ชันสำหรับขอสิทธิ์ (Permissions)
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }
  
  // --------------------------------------------------------------------------
  // 🔹 ฟังก์ชันเฉพาะสำหรับแจ้งเตือนความหนาแน่น (Bus)
  // --------------------------------------------------------------------------

  Future<void> showCrowdAlertForBus(Bus bus) async {
    // ใช้ bus.busId เป็น ID เพื่อให้ Notification แต่ละคันไม่ซ้ำกัน
    int notificationId = bus.busId.hashCode; 
    
    final String title = '🚨 ${bus.busName} (${bus.lineName}) หนาแน่นมาก!';
    
    // 💡 แก้ไข: ไม่แสดงจำนวนคน
    final String body = 
        'รถคันนี้มีความหนาแน่นสูง กรุณารอรถคันถัดไป';
    
    // 1. กำหนดรายละเอียด Channel (ใช้ Channel สำหรับ Crowd Alert โดยเฉพาะ)
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _crowdChannelId, 
      _crowdChannelName,
      channelDescription: _crowdChannelDescription,
      importance: Importance.max, // ระดับความสำคัญสูงสุด
      priority: Priority.high, 
      ticker: 'Bus Crowd Alert!',
      color: Colors.red, // กำหนดสีของไอคอนแจ้งเตือนเป็นสีแดง
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // 2. สั่งแสดง Notification
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'CROWD_BUS_${bus.busId}', // Payload เพื่อระบุประเภท Noti
    );
  }

  // --------------------------------------------------------------------------
  // 🔹 ฟังก์ชันเฉพาะสำหรับแจ้งเตือนความหนาแน่น (BusStop)
  // --------------------------------------------------------------------------

  Future<void> showCrowdAlertForStop(BusStop busStop) async {
    // ใช้ busStop.stopId เป็น ID เพื่อให้ Notification แต่ละป้ายไม่ซ้ำกัน
    int notificationId = busStop.stopId.hashCode;
    
    final String title = '⚠️ ป้าย ${busStop.name} คนรอเยอะมาก!';
    
    // 💡 แก้ไข: ไม่แสดงจำนวนคน
    final String body = 
        'โปรดทราบ: ที่ป้ายมีผู้รอใช้บริการหนาแน่นมาก (สาย ${busStop.lineName})';
    
    // 1. กำหนดรายละเอียด Channel (ใช้ Channel สำหรับ Crowd Alert โดยเฉพาะ)
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _crowdChannelId, 
      _crowdChannelName,
      channelDescription: _crowdChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Stop Crowd Alert!',
      color: Colors.orange, // กำหนดสีของไอคอนแจ้งเตือนเป็นสีส้ม
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // 2. สั่งแสดง Notification
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'CROWD_STOP_${busStop.stopId}', // Payload เพื่อระบุประเภท Noti
    );
  }
  
  // --------------------------------------------------------------------------
  // 🔹 ฟังก์ชันทั่วไป (เผื่อไว้สำหรับแจ้งเตือนอื่นๆ)
  // --------------------------------------------------------------------------

  Future<void> showGeneralNotification({
    required int id,
    required String title,
    required String body,
    String payload = 'GENERAL',
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'psu_bus_general', // Channel ID ทั่วไป
      'แจ้งเตือนทั่วไป',
      channelDescription: 'แจ้งเตือนสำหรับการมาถึงของรถหรือข้อมูลทั่วไป',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  // --------------------------------------------------------------------------
  // 🔹 ฟังก์ชันสำหรับยกเลิก Notification
  // --------------------------------------------------------------------------

  /// ยกเลิก Notification ตาม ID ที่กำหนด
  Future<void> cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// ยกเลิก Notification ทั้งหมด
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}