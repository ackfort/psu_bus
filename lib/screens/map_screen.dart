import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../models/bus_stop.dart';
import '../components/bus_stop_bottom_sheet.dart';
import '../services/firestore_service.dart';

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
  final FirestoreService _firestoreService =
      FirestoreService();

  BitmapDescriptor? redBusStopIcon;
  BitmapDescriptor? blueBusStopIcon;
  BitmapDescriptor? greenBusStopIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers().then((_) {
      _loadMapData();
      _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _updateMarkersOnly();
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
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

  Future<void> _loadMapData() async {
    try {
      final List<BusStop> busStops = await _firestoreService.fetchAllBusStops();
      final newMarkers = _createMarkers(busStops);
      setState(() {
        _markers.addAll(newMarkers);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load data from Firestore: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMarkersOnly() async {
    try {
      final List<BusStop> busStops = await _firestoreService.fetchAllBusStops();
      final Set<Marker> newMarkers = _createMarkers(busStops);

      if (!setEquals(_markers, newMarkers)) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      debugPrint("Failed to update markers from Firestore: $e");
    }
  }

  Set<Marker> _createMarkers(List<BusStop> stops) {
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

  bool setEquals(Set? set1, Set? set2) {
    if (set1 == null && set2 == null) {
      return true;
    }
    if (set1 == null || set2 == null || set1.length != set2.length) {
      return false;
    }
    return set1.every((element) => set2.contains(element));
  }

  Future<void> _openGoogleMap(double lat, double lng) async {
    // Corrected Uri to open a general map view focused on the location
    final Uri url = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot open Google Maps.';
    }
  }

  Future<void> _openGoogleMapDirections(double lat, double lng) async {
    final Uri url = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot open directions in Google Maps.';
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
                selectedBusStopId: _selectedBusStop!.stopId,
                selectedBusLine: _selectedBusStop!.busLine,
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