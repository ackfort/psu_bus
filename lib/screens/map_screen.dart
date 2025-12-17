// map_screen.dart (ฉบับสมบูรณ์ที่แก้ไขแล้ว)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../models/bus_stop.dart';
import '../models/bus.dart';
import '../components/bus_stop_bottom_sheet.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _hatYaiCenter = const LatLng(7.007692, 100.500510);
  bool _isLoading = true;
  final Set<Marker> _busStopMarkers =
      {}; // Markers สำหรับป้ายรถเมล์ (โหลดครั้งเดียว)
  final Set<Marker> _busMarkers = {}; // Markers สำหรับรถบัส (อัปเดต Real-time)
  BusStop? _selectedBusStop;
  bool _showBottomSheet = false;
  final FirestoreService _firestoreService = FirestoreService();

  // Icons สำหรับป้ายรถเมล์
  BitmapDescriptor? redBusStopIcon;
  BitmapDescriptor? blueBusStopIcon;
  BitmapDescriptor? greenBusStopIcon;

  // Icons สำหรับรถบัส (ใช้เพียงไฟล์เดียวตามที่ระบุ)
  BitmapDescriptor? greenBusIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers().then((_) {
      _loadBusStopData(); // โหลดป้ายรถเมล์ครั้งเดียว
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCustomMarkers() async {
    // โหลด Icon สำหรับป้ายรถเมล์
    redBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_red.png',
      70,
    );
    blueBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_blue.png',
      70,
    );
    greenBusStopIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_stop_green.png',
      70,
    );

    // โหลด Icon สำหรับรถบัส (ใช้ greenBusIcon สำหรับรถบัสทุกสาย)
    greenBusIcon = await _getBitmapDescriptorFromAssetBytes(
      'assets/images/bus_green.png',
      80,
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

  // โหลดข้อมูลป้ายรถเมล์ (Bus Stops) ครั้งเดียว
  Future<void> _loadBusStopData() async {
    try {
      final List<BusStop> busStops = await _firestoreService.fetchAllBusStops();
      final newMarkers = _createBusStopMarkers(busStops);
      setState(() {
        _busStopMarkers.addAll(newMarkers);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load bus stop data from Firestore: $e");
      setState(() => _isLoading = false);
    }
  }

  // สร้าง Markers สำหรับรถบัสจากข้อมูล List<Bus> ที่ได้รับ Real-time
  Set<Marker> _createBusMarkers(List<Bus> buses) {
    final Set<Marker> markers = {};
    // ใช้ greenBusIcon สำหรับรถบัสทุกสาย
    BitmapDescriptor? markerIcon = greenBusIcon;

    for (final bus in buses) {
      markers.add(
        Marker(
          markerId: MarkerId('bus_${bus.busId}'),
          position: LatLng(bus.latitude, bus.longitude),
          icon:
              markerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: bus.busName,
            snippet: 'ผู้โดยสาร: ${bus.passengerCount} (${bus.status})',
          ),
        ),
      );
    }
    return markers;
  }

  // สร้าง Markers สำหรับป้ายรถเมล์
  Set<Marker> _createBusStopMarkers(List<BusStop> stops) {
    final Set<Marker> markers = {};
    for (final stop in stops) {
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

  Future<void> _openGoogleMap(double lat, double lng) async {
    // แก้ไข URL ให้ถูกต้องเพื่อเปิดแผนที่ที่พิกัดนั้น
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ใช้ fallback URL ที่เป็นสากลมากขึ้น
      final Uri fallbackUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lng');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Cannot open Google Maps or Apple Maps.';
      }
    }
  }

  Future<void> _openGoogleMapDirections(double lat, double lng) async {
    final Uri url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback for web or non-Android devices (using general URL)
      final Uri fallbackUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Cannot open directions in Google Maps.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;

    return Scaffold(
      body: Stack(
        children: [
          // **ใช้ StreamBuilder เพื่อรับข้อมูลรถบัสแบบ Real-time**
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.streamAllBuses(),
            builder: (context, snapshot) {
              // 1. แสดง Loading Screen ในการโหลดครั้งแรก
              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. จัดการข้อมูลที่ได้รับ Real-time
              if (snapshot.hasData) {
                final List<Bus> buses =
                    snapshot.data!.docs
                        .map((doc) => Bus.fromFirestore(doc))
                        .toList();

                // อัปเดต Marker รถบัส
                _busMarkers.clear();
                _busMarkers.addAll(_createBusMarkers(buses));
              } else if (snapshot.hasError) {
                debugPrint('Error loading bus data: ${snapshot.error}');
              }

              // **รวม Marker ทั้งหมด** (ป้ายรถเมล์ + รถบัส)
              final Set<Marker> allMarkers = _busStopMarkers.union(_busMarkers);

              // 3. แสดงแผนที่
              return GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  // ตั้งค่าเริ่มต้นของกล้อง (ทำเพียงครั้งเดียว)
                  if (_busStopMarkers.isNotEmpty) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_hatYaiCenter, 17),
                    );
                  }
                },
                initialCameraPosition: CameraPosition(
                  target: _hatYaiCenter,
                  zoom: 17,
                ),
                markers: allMarkers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onTap: (position) {
                  setState(() {
                    _showBottomSheet = false;
                  });
                },
              );
            },
          ),

          // แสดง Bottom Sheet เมื่อมีป้ายรถเมล์ถูกเลือก
          if (_showBottomSheet && _selectedBusStop != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPadding,
              child: BusStopBottomSheet(
                selectedBusStop: _selectedBusStop!,
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
