import '../models/bus_stop.dart';

class BusStopMockData {
  static const List<BusStop> busStops = [
    BusStop(
      stopId: 'stop_hdy_001',
      name: 'ป้ายมหาวิทยาลัยหาดใหญ่',
      latitude: 7.0084,
      longitude: 100.4967,
      passengerCount: 10,
      busLine: 'red',
    ),
    BusStop(
      stopId: 'stop_hdy_002',
      name: 'ป้ายตลาดน้ำคลองแห',
      latitude: 6.9984,
      longitude: 100.4767,
      passengerCount: 5,
      busLine: 'blue',
    ),
    BusStop(
      stopId: 'stop_hdy_003',
      name: 'ป้ายสถานีรถไฟหาดใหญ่',
      latitude: 7.0184,
      longitude: 100.4867,
      passengerCount: 15,
      busLine: 'green',
    ),
    BusStop(
      stopId: 'stop_hdy_004',
      name: 'ป้ายเซ็นทรัลหาดใหญ่',
      latitude: 7.0054,
      longitude: 100.4807,
      passengerCount: 8,
      busLine: 'red',
    ),
  ];
}