import '../models/bus_stop.dart';

class BusStopMockData {
  static const List<BusStop> busStops = [
    BusStop(
      stopId: 'stop001',
      name: 'ป้ายมหาวิทยาลัย',
      latitude: 13.7563,
      longitude: 100.5018,
      passengerCount: 15,
      busLine: 'red',
    ),
    BusStop(
      stopId: 'stop002',
      name: 'ป้ายห้างสรรพสินค้า',
      latitude: 13.7462,
      longitude: 100.5341,
      passengerCount: 8,
      busLine: 'green',
    ),
    BusStop(
      stopId: 'stop003',
      name: 'ป้ายสถานีรถไฟ',
      latitude: 13.7365,
      longitude: 100.5601,
      passengerCount: 22,
      busLine: 'blue',
    ),
  ];
}