import '../models/bus.dart';

class BusMockData {
  static const List<Bus> buses = [
    Bus(
      busId: 'bus001',
      busName: 'กข 1234',
      latitude: 13.7563,
      longitude: 100.5018,
      passengerCount: 25,
      busLine: 'red',
    ),
    Bus(
      busId: 'bus002',
      busName: 'กข 5678',
      latitude: 13.7462,
      longitude: 100.5341,
      passengerCount: 12,
      busLine: 'green',
    ),
    Bus(
      busId: 'bus003',
      busName: 'กข 9012',
      latitude: 13.7365,
      longitude: 100.5601,
      passengerCount: 38,
      busLine: 'blue',
    ),
  ];
}