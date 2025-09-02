import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bus_stop.dart';
import '../mock_data/bus_stop_mock_data.dart';
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

  // Custom marker icons
  BitmapDescriptor? redBusStopIcon;
  BitmapDescriptor? blueBusStopIcon;
  BitmapDescriptor? greenBusStopIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers().then((_) {
      _loadMapData();
      _simulateLocation();
    });
  }

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

  void _loadMapData() {
    final busStops = BusStopMockData.busStops;

    for (final stop in busStops) {
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

      _markers.add(
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

    setState(() => _isLoading = false);
  }

  Future<void> _simulateLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openGoogleMap(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิด Google Maps ได้';
    }
  }

  Future<void> _openGoogleMapDirections(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
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
