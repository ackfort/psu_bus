import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_stop.dart';
import '../models/bus.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> streamSelectedBusStop(String stopId) {
    return _db.collection('busStops').doc(stopId).snapshots();
  }

  Stream<QuerySnapshot> streamSameLineBusStops(String busLine, String selectedStopId) {
    return _db
        .collection('busStops')
        .where('busLine', isEqualTo: busLine)
        .where(FieldPath.documentId, isNotEqualTo: selectedStopId)
        .snapshots();
  }

  Stream<QuerySnapshot> streamSameLineBuses(String busLine) {
    return _db
        .collection('buses')
        .where('busLine', isEqualTo: busLine)
        .snapshots();
  }
  
  Future<List<BusStop>> fetchAllBusStops() async {
    final snapshot = await _db.collection('busStops').get();
    return snapshot.docs.map((doc) => BusStop.fromFirestore(doc)).toList();
  }
  
  Stream<QuerySnapshot> streamAllBusStops() {
    return _db.collection('busStops').snapshots();
  }
  
  Stream<QuerySnapshot> streamAllBuses() {
    return _db.collection('buses').snapshots();
  }

  Future<Map<String, dynamic>> fetchSameLineData(String busLine, String selectedStopId) async {
    final List<Future<QuerySnapshot>> futures = [
      _db
          .collection('busStops')
          .where('busLine', isEqualTo: busLine)
          .where(FieldPath.documentId, isEqualTo: selectedStopId)
          .limit(1)
          .get(),
      _db
          .collection('busStops')
          .where('busLine', isEqualTo: busLine)
          .where(FieldPath.documentId, isNotEqualTo: selectedStopId)
          .get(),
      _db
          .collection('buses')
          .where('busLine', isEqualTo: busLine)
          .get(),
    ];

    final results = await Future.wait(futures);
    
    final currentStopDoc = results[0].docs.isNotEmpty ? results[0].docs.first : null;
    final otherStopDocs = results[1].docs;
    final busDocs = results[2].docs;

    final BusStop? currentBusStop = currentStopDoc != null ? BusStop.fromFirestore(currentStopDoc) : null;
    final List<BusStop> sameLineStops = otherStopDocs
        .map((doc) => BusStop.fromFirestore(doc))
        .toList();
    final List<Bus> sameLineBuses = busDocs
        .map((doc) => Bus.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();

    return {
      'currentBusStop': currentBusStop,
      'sameLineStops': sameLineStops,
      'sameLineBuses': sameLineBuses,
    };
  }
}