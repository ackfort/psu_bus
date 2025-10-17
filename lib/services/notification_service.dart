import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static const String _crowdChannelId = 'psu_bus_crowd_alert';
  static const String _crowdChannelName = 'แจ้งเตือนความหนาแน่น';
  static const String _crowdChannelDescription =
      'แจ้งเตือนเมื่อจำนวนผู้โดยสารบนรถหรือที่ป้ายเกินเกณฑ์ที่กำหนด (19 คน)';

  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        debugPrint('Notification Payload: ${notificationResponse.payload}');
      },
    );

    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showCrowdAlertForBus(Bus bus) async {
    int notificationId = bus.busId.hashCode;

    final String title = '🚨 ${bus.busName} (${bus.lineName}) หนาแน่นมาก!';

    final String body = 'รถคันนี้มีความหนาแน่นสูง กรุณารอรถคันถัดไป';

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          _crowdChannelId,
          _crowdChannelName,
          channelDescription: _crowdChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Bus Crowd Alert!',
          color: Colors.red,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'CROWD_BUS_${bus.busId}',
    );
  }

  Future<void> showCrowdAlertForStop(BusStop busStop) async {
    int notificationId = busStop.stopId.hashCode;

    final String title = '⚠️ ป้าย ${busStop.name} คนรอเยอะมาก!';

    final String body =
        'โปรดทราบ: ที่ป้ายมีผู้รอใช้บริการหนาแน่นมาก (สาย ${busStop.lineName})';

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          _crowdChannelId,
          _crowdChannelName,
          channelDescription: _crowdChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Stop Crowd Alert!',
          color: Colors.orange,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'CROWD_STOP_${busStop.stopId}',
    );
  }

  Future<void> showGeneralNotification({
    required int id,
    required String title,
    required String body,
    String payload = 'GENERAL',
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'psu_bus_general',
          'แจ้งเตือนทั่วไป',
          channelDescription: 'แจ้งเตือนสำหรับการมาถึงของรถหรือข้อมูลทั่วไป',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
