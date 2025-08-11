import '../models/bus.dart';

class BusMockData {
  static const List<Bus> buses = [
    Bus(
      busId: 'bus_hdy_001',
      busName: 'หาดใหญ่ 01',
      latitude: 7.0084,  // ตำแหน่งในหาดใหญ่
      longitude: 100.4767,
      passengerCount: 15,
      busLine: 'red',
    ),
    Bus(
      busId: 'bus_hdy_002',
      busName: 'หาดใหญ่ 02',
      latitude: 6.9984,
      longitude: 100.4867,
      passengerCount: 8,
      busLine: 'blue',
    ),
    Bus(
      busId: 'bus_hdy_003',
      busName: 'หาดใหญ่ 03',
      latitude: 7.0184,
      longitude: 100.4667,
      passengerCount: 22,
      busLine: 'green',
    ),
  ];
}