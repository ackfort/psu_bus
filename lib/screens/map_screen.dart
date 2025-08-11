import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui; // Import for ui.Image
import 'package:flutter/services.dart'; // Import for rootBundle

import '../models/bus_stop.dart';
import '../mock_data/bus_stop_mock_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _hatYaiCenter = const LatLng(7.0084, 100.4767); // จุดกลางเมืองหาดใหญ่
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Declare BitmapDescriptors for custom markers
  BitmapDescriptor? redBusStopIcon;
  BitmapDescriptor? blueBusStopIcon;
  BitmapDescriptor? greenBusStopIcon;

  @override
  void initState() {
    super.initState();
    // โหลดรูปภาพ Marker ก่อน แล้วค่อยโหลดข้อมูลแผนที่
    _loadCustomMarkers().then((_) {
      _loadMapData();
      _simulateLocation(); // จำลองตำแหน่งแทนการใช้ GPS จริง
    });
  }

  // Function to load custom marker images
  Future<void> _loadCustomMarkers() async {
    // กำหนดพาธของรูปภาพในโฟลเดอร์ assets/images และตั้งค่าขนาดใหม่ (เช่น 150)
    redBusStopIcon = await _getBitmapDescriptorFromAssetBytes('assets/images/bus_stop_red.png', 200); // เพิ่มขนาด Marker
    blueBusStopIcon = await _getBitmapDescriptorFromAssetBytes('assets/images/bus_stop_blue.png', 200); // เพิ่มขนาด Marker
    greenBusStopIcon = await _getBitmapDescriptorFromAssetBytes('assets/images/bus_stop_green.png', 200); // เพิ่มขนาด Marker
  }

  // Helper function to convert asset image to BitmapDescriptor
  // width คือขนาดความกว้างของรูปภาพ Marker ที่ต้องการ (เพื่อควบคุมขนาดบนแผนที่)
  Future<BitmapDescriptor> _getBitmapDescriptorFromAssetBytes(String path, int width) async {
    final ByteData byteData = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(), targetWidth: width);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedByteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedByteData == null) {
      throw Exception("Failed to resize image for BitmapDescriptor: $path");
    }
    return BitmapDescriptor.fromBytes(resizedByteData.buffer.asUint8List());
  }

  void _loadMapData() {
    final busStops = BusStopMockData.busStops;

    // แสดงเฉพาะป้ายจอดรถ และใช้สีตามสาย
    for (final stop in busStops) {
      BitmapDescriptor? markerIcon;
      // เลือก Marker Icon ตาม busLine
      switch (stop.busLine) {
        case 'red':
          markerIcon = redBusStopIcon;
          break;
        case 'blue':
          markerIcon = blueBusStopIcon;
          break;
        case 'green':
          markerIcon = greenBusStopIcon;
          break;
        default:
          markerIcon = BitmapDescriptor.defaultMarker; // ใช้ Marker เริ่มต้นหากไม่มีรูปภาพที่ตรงกัน
      }

      _markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.stopId}'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: markerIcon ?? BitmapDescriptor.defaultMarker, // ใช้ custom icon หรือ default หากเป็น null
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: 'สาย ${_getLineName(stop.busLine)} | ผู้รอ: ${stop.passengerCount} คน',
          ),
        ),
      );
    }

    // เส้นทางรถโดยสาร (ลบสายสีแดงออก)
    _polylines.addAll([
      _createRoute('blue', Colors.blue, busStops),
      _createRoute('green', Colors.green, busStops),
      // _createRoute('red', Colors.red, busStops), // บรรทัดนี้ถูกลบออกแล้ว
    ]);

    setState(() => _isLoading = false);
  }

  // สร้าง Polyline สำหรับเส้นทางรถแต่ละสาย
  Polyline _createRoute(String line, Color color, List<BusStop> stops) {
    return Polyline(
      polylineId: PolylineId('route_$line'),
      points: stops
          .where((stop) => stop.busLine == line) // กรองเฉพาะป้ายที่อยู่ในสายเดียวกัน
          .map((stop) => LatLng(stop.latitude, stop.longitude))
          .toList(),
      color: color,
      width: 4,
    );
  }

  // ฟังก์ชันช่วยในการแสดงชื่อสายรถ
  String _getLineName(String line) {
    switch (line) {
      case 'red':
        return 'สายสีแดง';
      case 'blue':
        return 'สายสีน้ำเงิน';
      case 'green':
        return 'สายสีเขียว';
      default:
        return 'สาย $line';
    }
  }

  // ฟังก์ชันจำลองการโหลดข้อมูล (สามารถใช้สำหรับ GPS จริงได้ในอนาคต)
  Future<void> _simulateLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    // สามารถเพิ่มโค้ดสำหรับการขอตำแหน่ง GPS จริงที่นี่
    // เช่น geolocator package
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดง Loading ขณะโหลดข้อมูล
          : GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                // ตั้งค่าเริ่มต้นให้แผนที่โฟกัสไปที่หาดใหญ่
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_hatYaiCenter, 14),
                );
              },
              initialCameraPosition: CameraPosition(
                target: _hatYaiCenter,
                zoom: 14,
              ),
              markers: _markers, // แสดง Marker ที่สร้างขึ้น
              polylines: _polylines, // แสดง Polyline เส้นทาง
              myLocationEnabled: true, // เปิดใช้งานปุ่มตำแหน่งปัจจุบันของผู้ใช้
              myLocationButtonEnabled: true,
            ),
    );
  }
}