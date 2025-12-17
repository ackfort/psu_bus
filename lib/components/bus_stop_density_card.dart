import 'package:flutter/material.dart';
import '../models/bus_stop.dart';

class BusStopDensityCard extends StatelessWidget {
  final BusStop busStop;
  final bool isSelected;
  final VoidCallback? onTap;

  const BusStopDensityCard({
    super.key,
    required this.busStop,
    this.isSelected = false,
    this.onTap,
  });

  Color _getDensityColor(int passengerCount) {
    if (passengerCount > 19) return Colors.red;
    if (passengerCount > 11) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color borderColor =
        isSelected
            ? busStop.lineColor
            : isDarkMode
            ? Colors.grey.shade700
            : Colors.grey.shade300;
    final Color textColor = isDarkMode ? Colors.white : Colors.grey.shade800;
    final densityColor = _getDensityColor(busStop.passengerCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: busStop.lineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          busStop.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: busStop.lineColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            busStop.lineName,
                            style: TextStyle(
                              fontSize: 12,
                              color: busStop.lineColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: busStop.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: busStop.statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      busStop.status,
                      style: TextStyle(
                        color: busStop.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: busStop.lineColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: busStop.lineColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ผู้โดยสาร',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${busStop.passengerCount} คน',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 80,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: busStop.passengerCount / 25,
                        backgroundColor: Colors.grey.shade300,
                        color: densityColor,
                        minHeight: 6,
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
}
