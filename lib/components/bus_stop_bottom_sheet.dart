//bus_stop_bottom_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
import '../models/bus.dart';

class BusStopBottomSheet extends StatefulWidget {
  final String selectedBusStopId;
  final String selectedBusLine;
  final Function() onClose;
  final Function(double, double) onOpenMap;
  final Function(double, double) onOpenDirections;
  final BusStop selectedBusStop;

  const BusStopBottomSheet({
    Key? key,
    required this.selectedBusStop,
    required this.onClose,
    required this.onOpenMap,
    required this.onOpenDirections,
    required this.selectedBusStopId,
    required this.selectedBusLine,
  }) : super(key: key);

  @override
  _BusStopBottomSheetState createState() => _BusStopBottomSheetState();
}

class _BusStopBottomSheetState extends State<BusStopBottomSheet> {
  late Timer _timer;
  int _totalCombinedPassengers = 0;
  List<BusStop> _sameLineStops = [];
  List<Bus> _sameLineBuses = [];
  BusStop? _currentBusStop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndUpdate(); // Fetch data immediately on load
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDataAndUpdate(); // Fetch data every 1 second
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchDataAndUpdate() async {
    try {
      // Fetch current bus stop data
      final currentStopDoc = await FirebaseFirestore.instance
          .collection('busStops')
          .doc(widget.selectedBusStopId)
          .get();
      _currentBusStop = BusStop.fromFirestore(currentStopDoc);

      // Fetch other stops on the same line
      final sameLineStopsQuery = await FirebaseFirestore.instance
          .collection('busStops')
          .where('busLine', isEqualTo: widget.selectedBusLine)
          .where(FieldPath.documentId, isNotEqualTo: widget.selectedBusStopId)
          .get();
      _sameLineStops = sameLineStopsQuery.docs
          .map((doc) => BusStop.fromFirestore(doc))
          .toList();

      // Fetch buses on the same line
      final sameLineBusesQuery = await FirebaseFirestore.instance
          .collection('buses')
          .where('busLine', isEqualTo: widget.selectedBusLine)
          .get();
      _sameLineBuses = sameLineBusesQuery.docs
          .map((doc) => Bus.fromFirestore(doc.data()))
          .toList();

      // Calculate total combined passengers
      int totalCombined = _currentBusStop!.passengerCount;
      for (var stop in _sameLineStops) {
        totalCombined += stop.passengerCount;
      }
      for (var bus in _sameLineBuses) {
        totalCombined += bus.passengerCount;
      }

      // Update state to trigger UI rebuild
      setState(() {
        _totalCombinedPassengers = totalCombined;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors gracefully, for example, by logging or showing a snackbar
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error fetching data: $e');
    }
  }

  Color _getStopDensityColor(int passengerCount) {
    if (passengerCount > 25) return Colors.red[600]!;
    if (passengerCount > 15) return Colors.orange[600]!;
    return Colors.green[600]!;
  }

  Color _getStopDensityBackground(int passengerCount) {
    if (passengerCount > 25) return Colors.red[50]!;
    if (passengerCount > 15) return Colors.orange[50]!;
    return Colors.green[50]!;
  }

  Color _getLineDensityColor(int totalPassengers) {
    if (totalPassengers >= 200) return Colors.red[600]!;
    if (totalPassengers >= 100) return Colors.amber[600]!;
    return Colors.green[600]!;
  }

  Color _getLineDensityBackground(int totalPassengers) {
    if (totalPassengers >= 200) return Colors.red[50]!;
    if (totalPassengers >= 100) return Colors.amber[50]!;
    return Colors.green[50]!;
  }

  String _getLineDensityStatus(int totalPassengers) {
    if (totalPassengers >= 200) return 'หนาแน่นมาก';
    if (totalPassengers >= 100) return 'ปานกลาง';
    return 'ไม่หนาแน่น';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentBusStop == null) {
      return Container(); // Or a loading indicator
    }

    final lineColor = _currentBusStop!.lineColor;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 10;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomPadding,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentBusStop!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          _currentBusStop!.lineName,
                          style: TextStyle(
                            color: lineColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.directions_bus,
                      iconColor: _getStopDensityColor(_currentBusStop!.passengerCount),
                      title: 'ป้ายนี้',
                      value: '${_currentBusStop!.passengerCount} คน',
                      status: _currentBusStop!.status,
                      backgroundColor: _getStopDensityBackground(_currentBusStop!.passengerCount),
                      valueColor: _getStopDensityColor(_currentBusStop!.passengerCount),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.alt_route,
                      iconColor: _getLineDensityColor(_totalCombinedPassengers),
                      title: 'รวมทั้งสาย',
                      value: '$_totalCombinedPassengers คน',
                      status: _getLineDensityStatus(_totalCombinedPassengers),
                      backgroundColor: _getLineDensityBackground(_totalCombinedPassengers),
                      valueColor: _getLineDensityColor(_totalCombinedPassengers),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bus stops on the same line list
              if (_sameLineStops.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.list, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'ป้ายอื่นในสายนี้',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _buildDensityLegendItem('น้อย', Colors.green),
                              const SizedBox(width: 8),
                              _buildDensityLegendItem('ปานกลาง', Colors.amber),
                              const SizedBox(width: 8),
                              _buildDensityLegendItem('มาก', Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _sameLineStops.length,
                          itemBuilder: (context, index) {
                            final stop = _sameLineStops[index];
                            final densityColor = _getStopDensityColor(stop.passengerCount);
                            return Container(
                              decoration: BoxDecoration(
                                color: index.isOdd ? Colors.grey.shade50 : Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stop.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStopDensityBackground(stop.passengerCount),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: densityColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: densityColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${stop.passengerCount} คน',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: densityColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              if (_sameLineStops.isNotEmpty) const SizedBox(height: 16),
              // Buses on the same line list
              if (_sameLineBuses.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.directions_bus_filled, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'รถเมล์ในสายนี้',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _sameLineBuses.length,
                          itemBuilder: (context, index) {
                            final bus = _sameLineBuses[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: index.isOdd ? Colors.grey.shade50 : Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bus.busName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bus.statusColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: bus.statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: bus.statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${bus.passengerCount} คน',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: bus.statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              if (_sameLineBuses.isNotEmpty) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.map_outlined, size: 20, color: lineColor),
                      label: Text(
                        'ดูบนแผนที่',
                        style: TextStyle(color: lineColor, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => widget.onOpenMap(_currentBusStop!.latitude, _currentBusStop!.longitude),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: lineColor,
                        side: BorderSide(color: lineColor.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions, size: 20, color: Colors.white),
                      label: const Text(
                        'นำทาง',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => widget.onOpenDirections(_currentBusStop!.latitude, _currentBusStop!.longitude),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lineColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        shadowColor: lineColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDensityLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String status,
    required Color backgroundColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}