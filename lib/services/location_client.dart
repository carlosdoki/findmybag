import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationClient {
  final Location _location = Location();
  final CollectionReference malasCollection = FirebaseFirestore.instance
      .collection('locations')
      .doc('mala')
      .collection('rastreamento');

  Stream<LatLng> get locationStream => _location.onLocationChanged
      .map((event) => LatLng(event.latitude!, event.longitude!));

  void init() async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      await _location.requestService();
    }
    var permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
    }
    if (permissionStatus == PermissionStatus.granted) {
      await _location.enableBackgroundMode();
      await _location.changeNotificationOptions(
          title: 'Geolocation', subtitle: 'Geolocation detection');
    }
  }

  Future<bool> isServiceEnabled() async {
    return _location.serviceEnabled();
  }

  Stream<QuerySnapshot> get malas {
    return malasCollection.orderBy('tipo', descending: true).snapshots();
  }
}
