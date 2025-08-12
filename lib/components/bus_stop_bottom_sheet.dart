import 'package:flutter/material.dart';
import '../models/bus_stop.dart';

class BusStopBottomSheet extends StatelessWidget {
  final BusStop selectedBusStop;
  final Function() onClose;
  final Function(double, double) onOpenMap;
  final Function(double, double) onOpenDirections;

  const BusStopBottomSheet({
    super.key,
    required this.selectedBusStop,
    required this.onClose,
    required this.onOpenMap,
    required this.onOpenDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  color: _getLineColor(selectedBusStop.busLine),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedBusStop.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLineName(selectedBusStop.busLine),
                        style: TextStyle(
                          color: _getLineColor(selectedBusStop.busLine),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'ผู้รอรถ: ${selectedBusStop.passengerCount} คน',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    onOpenMap(
                      selectedBusStop.latitude,
                      selectedBusStop.longitude,
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: const Text("Info / More"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    onOpenDirections(
                      selectedBusStop.latitude,
                      selectedBusStop.longitude,
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text("Directions"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Color _getLineColor(String line) {
    switch (line) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}