import 'package:flutter/material.dart';

class DensityFilterSection extends StatelessWidget {
  final String selectedLine;
  final ValueChanged<String> onLineChanged;
  final bool showBuses;
  final ValueChanged<bool> onBusesChanged;
  final bool showBusStops;
  final ValueChanged<bool> onBusStopsChanged;

  const DensityFilterSection({
    super.key,
    required this.selectedLine,
    required this.onLineChanged,
    required this.showBuses,
    required this.onBusesChanged,
    required this.showBusStops,
    required this.onBusStopsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          // กรองตามสาย
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 20),
              const SizedBox(width: 8),
              Text('สายรถเมล์:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedLine,
                  items: [
                    'ทั้งหมด',
                    'สายสีเขียว',
                    'สายสีแดง',
                    'สายสีน้ำเงิน',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) => onLineChanged(newValue!),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // กรองตามประเภท
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, size: 20),
              const SizedBox(width: 8),
              Text('แสดง:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('รถเมล์'),
                selected: showBuses,
                onSelected: onBusesChanged,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: showBuses 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('ป้ายรถเมล์'),
                selected: showBusStops,
                onSelected: onBusStopsChanged,
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: showBusStops 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}