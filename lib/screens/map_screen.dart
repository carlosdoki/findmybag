// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmybag/services/location_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/app_text.dart';

class MapScreen extends StatefulWidget {
  static const id = 'map_screen.dart';
  const MapScreen({
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _locationClient = LocationClient();
  final _mapController = MapController();
  final _points = <LatLng>[];
  LatLng? _currPosition;
  LatLng? _currPositionAnt;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _locationClient.init();
    _listenLocation();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _listenLocation();
      // _calculateDistance();
    });
  }

  void _listenLocation() async {
    if (!_isServiceRunning && await _locationClient.isServiceEnabled()) {
      _isServiceRunning = true;
      _locationClient.locationStream.listen((event) async {
        setState(() {
          _currPosition = event;
        });
        _points.add(_currPosition!);
        if (_currPositionAnt != _currPosition) {
          _currPositionAnt = _currPosition;
          await saveLocationData(
              _currPosition!.latitude, _currPosition!.longitude);
        }
      });
    } else {
      _isServiceRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LayoutBuilder(builder: (context, _) {
        return _currPosition == null
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 500,
                    width: double.maxFinite,
                    // margin: const EdgeInsets.only(top: 60, right: 20, left: 20),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currPosition,
                        // zoom: 20,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                              points: _points,
                              color: Colors.blue,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        if (_currPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currPosition!,
                                builder: (context) =>
                                    const Icon(Icons.location_on),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        AppText(text: 'Mala'),
                        SizedBox(height: 10),
                        AppText(text: 'Mala'),
                        SizedBox(height: 10),
                        AppText(text: 'Mala'),
                        SizedBox(height: 10),
                        AppText(text: 'Mala'),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              );
      })),
    );
  }
}

saveLocationData(double latitude, double longitude) {
  CollectionReference locations = FirebaseFirestore.instance
      .collection('locations')
      .doc('celular')
      .collection('historico');

  return locations
      .add({'latitude': latitude, 'longitude': longitude})
      .then((value) => print('Location data added'))
      .catchError((error) => print('Failed to add location data: $error'));
}
