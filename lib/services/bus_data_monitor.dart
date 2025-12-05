import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus.dart';
import '../models/bus_stop.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

const int _CROWD_THRESHOLD = 19;

class BusDataMonitor {
  // Singleton Pattern
  BusDataMonitor._internal();
  static final BusDataMonitor _instance = BusDataMonitor._internal();
  factory BusDataMonitor() => _instance;

  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription<QuerySnapshot>? _busSubscription;
  StreamSubscription<QuerySnapshot>? _busStopSubscription;
  
  late final SharedPreferences _prefs;
  static const String _KEY_CROWDED_BUSES = 'crowdedBusIds';
  static const String _KEY_CROWDED_STOPS = 'crowdedStopIds';

  Future<void> _loadPersistentState() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Set<String> _getCrowdedIds(String key) {
    return _prefs.getStringList(key)?.toSet() ?? {};
  }

  Future<void> _saveCrowdedIds(String key, Set<String> ids) async {
    await _prefs.setStringList(key, ids.toList());
  }


  void startMonitoring() async {
    await _loadPersistentState();

    stopMonitoring();

    _busSubscription = _firestoreService.streamAllBuses().listen(
      _handleBusUpdates,
      onError: (error) => print('Bus Stream Error: $error'),
    );

    _busStopSubscription = _firestoreService.streamAllBusStops().listen(
      _handleBusStopUpdates,
      onError: (error) => print('Bus Stop Stream Error: $error'),
    );
  }

  void _handleBusUpdates(QuerySnapshot snapshot) {
    Set<String> crowdedBuses = _getCrowdedIds(_KEY_CROWDED_BUSES);
    bool stateChanged = false;

    for (var doc in snapshot.docs) {
      final Bus bus = Bus.fromFirestore(doc);
      final String busId = bus.busId; 

      if (bus.passengerCount > _CROWD_THRESHOLD) {
        
        if (!crowdedBuses.contains(busId)) {
          _notificationService.showCrowdAlertForBus(bus);
          crowdedBuses.add(busId);
          stateChanged = true;
        }
        
      } else {
        
        if (crowdedBuses.contains(busId)) {
          _notificationService.cancelNotificationById(busId.hashCode);
          crowdedBuses.remove(busId);
          stateChanged = true;
        }
      }
    }
    
    if (stateChanged) {
      _saveCrowdedIds(_KEY_CROWDED_BUSES, crowdedBuses);
    }
  }

  void _handleBusStopUpdates(QuerySnapshot snapshot) {
    Set<String> crowdedStops = _getCrowdedIds(_KEY_CROWDED_STOPS);
    bool stateChanged = false;

    for (var doc in snapshot.docs) {
      final BusStop busStop = BusStop.fromFirestore(doc);
      final String stopId = busStop.stopId; 

      if (busStop.passengerCount > _CROWD_THRESHOLD) {
        
        if (!crowdedStops.contains(stopId)) {
          _notificationService.showCrowdAlertForStop(busStop);
          crowdedStops.add(stopId);
          stateChanged = true;
        }
        
      } else {
        
        if (crowdedStops.contains(stopId)) {
          _notificationService.cancelNotificationById(stopId.hashCode);
          crowdedStops.remove(stopId);
          stateChanged = true;
        }
      }
    }
    
    if (stateChanged) {
      _saveCrowdedIds(_KEY_CROWDED_STOPS, crowdedStops);
    }
  }

  void stopMonitoring() {
    _busSubscription?.cancel();
    _busStopSubscription?.cancel();
  }
}