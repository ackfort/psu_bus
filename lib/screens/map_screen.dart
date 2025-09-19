//map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/bus_stop.dart';
import '../components/bus_stop_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _hatYaiCenter = const LatLng(7.007692, 100.500510);
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  BusStop? _selectedBusStop;
  bool _showBottomSheet = false;
  Timer? _updateTimer;

  // Custom marker icons
  BitmapDescriptor? redBusStopIcon;
  BitmapDescriptor? blueBusStopIcon;
  BitmapDescriptor? greenBusStopIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers().then((_) {
      // โหลดข้อมูลครั้งแรก
      _loadMapData();
      // ตั้งค่า Timer ให้อัปเดตทุกๆ 3 วินาที
      _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _updateMarkersOnly(); // เรียกเมธอดใหม่เพื่ออัปเดตเฉพาะ markers
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel(); // ยกเลิก Timer เมื่อหน้าถูกปิด
    super.dispose();
  }

  // โหลด icon marker
  Future<void> _loadCustomMarkers() async {
    redBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_red.png',
      200,
    );
    blueBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_blue.png',
      200,
    );
    greenBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_green.png',
      200,
    );
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromAssetBytes(
    String path,
    int width,
  ) async {
    final ByteData byteData = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedByteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (resizedByteData == null) {
      throw Exception("Failed to resize image for BitmapDescriptor: $path");
    }
    return BitmapDescriptor.fromBytes(resizedByteData.buffer.asUint8List());
  }

  // เมธอดสำหรับโหลดข้อมูลครั้งแรก
  Future<void> _loadMapData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('busStops').get();
      _createMarkersFromSnapshot(snapshot);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("โหลดข้อมูลจาก Firestore ล้มเหลว: $e");
      setState(() => _isLoading = false);
    }
  }

  // เมธอดใหม่: อัปเดตเฉพาะ markers โดยไม่ต้อง rebuild ทั้งหน้า
  Future<void> _updateMarkersOnly() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('busStops').get();
      final Set<Marker> newMarkers = _createMarkersFromSnapshot(snapshot);

      // ตรวจสอบว่ามีข้อมูลเปลี่ยนแปลงหรือไม่ก่อนเรียก setState
      if (!setEquals(_markers, newMarkers)) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      debugPrint("อัปเดตข้อมูลจาก Firestore ล้มเหลว: $e");
    }
  }

  // Helper method: สร้าง markers จาก snapshot
  Set<Marker> _createMarkersFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Set<Marker> markers = {};
    for (final doc in snapshot.docs) {
      final stop = BusStop.fromFirestore(doc);
      BitmapDescriptor? markerIcon;
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
          markerIcon = BitmapDescriptor.defaultMarker;
      }
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.stopId}'),
          position: LatLng(stop.latitude, stop.longitude),
          icon: markerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            setState(() {
              _selectedBusStop = stop;
              _showBottomSheet = true;
            });
          },
        ),
      );
    }
    return markers;
  }

  // Helper method เพื่อเปรียบเทียบ Set
  bool setEquals(Set? set1, Set? set2) {
    if (set1 == null && set2 == null) {
      return true;
    }
    if (set1 == null || set2 == null || set1.length != set2.length) {
      return false;
    }
    return set1.every((element) => set2.contains(element));
  }

  // เปิด Google Maps
  Future<void> _openGoogleMap(double lat, double lng) async {
    final Uri url = Uri.parse('http://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิด Google Maps ได้';
    }
  }

  // เปิด Google Maps สำหรับนำทาง
  Future<void> _openGoogleMapDirections(double lat, double lng) async {
    final Uri url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิดโหมดนำทางใน Google Maps ได้';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;

    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_hatYaiCenter, 17),
                  );
                },
                initialCameraPosition: CameraPosition(
                  target: _hatYaiCenter,
                  zoom: 17,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (position) {
                  setState(() {
                    _showBottomSheet = false;
                  });
                },
              ),
          if (_showBottomSheet && _selectedBusStop != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPadding,
              child: BusStopBottomSheet(
                selectedBusStop: _selectedBusStop!,
                selectedBusStopId: _selectedBusStop!.stopId, // เพิ่มบรรทัดนี้
                selectedBusLine: _selectedBusStop!.busLine, // เพิ่มบรรทัดนี้
                onClose: () {
                  setState(() {
                    _showBottomSheet = false;
                  });
                },
                onOpenMap: _openGoogleMap,
                onOpenDirections: _openGoogleMapDirections,
              ),
            ),
        ],
      ),
    );
  }
}
