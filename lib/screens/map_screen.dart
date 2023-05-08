// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmybag/services/location_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/app_text.dart';

class MapScreen extends StatefulWidget {
  static const id = 'map_screen.dart';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final _locationClient = LocationClient();
  final _mapController = MapController();
  final _points = <LatLng>[];
  final _malas = <LatLng>[];
  LatLng? _currMala;
  LatLng? _currPosition;
  LatLng? _currPositionAnt;
  bool _isServiceRunning = false;
  int _contador = 0;

  @override
  void initState() {
    super.initState();
    _locationClient.init();
    _listenLocation();
    _getMalas();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _listenLocation();
      // _calculateDistance();
    });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getMalas();
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);
    return Scaffold(
      body: _currPosition == null
          ? const CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 600,
                  width: double.maxFinite,
                  // margin: const EdgeInsets.only(top: 60, right: 20, left: 20),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currPosition,
                      zoom: 18,
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
                            color: Colors.brown,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylineCulling: false,
                        polylines: [
                          Polyline(
                            points: _malas,
                            color: Colors.blue,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                      // if (_currPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currPosition!,
                            builder: (context) => const Icon(
                              Icons.person,
                            ),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currMala!,
                            builder: (context) => const Icon(
                              Icons.work,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      //Mala
                      // PolylineLayer(
                      //   polylineCulling: false,
                      //   polylines: [
                      //     Polyline(
                      //       points: _malas,
                      //       color: Colors.brown,
                      //       strokeWidth: 4,
                      //     ),
                      //   ],
                      // ),
                      // if (_currMala != null)
                      //   MarkerLayer(
                      //     markers: [
                      //       Marker(
                      //         point: _currMala!,
                      //         builder: (context) => const Icon(Icons.backpack),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      labelPadding: EdgeInsets.only(right: 20, left: 20),
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          text: 'Mala',
                        ),
                        Tab(
                          text: 'Bagagem',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  width: double.maxFinite,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage("assets/travelbag.jpeg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Mala despachada',
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Última atualização:' +
                                        DateFormat.yMd()
                                            .add_jm()
                                            .format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage("assets/bag.jpeg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Bagagem de mao',
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Última atualizaçao:' +
                                        DateFormat.yMd()
                                            .add_jm()
                                            .format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _getMalas() {
    final CollectionReference malasCollection = FirebaseFirestore.instance
        .collection('locations')
        .doc('mala')
        .collection('rastreamento');

    setState(() {
      LatLng _ramdom = LatLng(-23.575416948440562, -46.62334877113724);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.576416948440580, -46.62334877213750);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.577416948441600, -46.62334877313755);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.578426948442600, -46.62335877413770);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.578436948442600, -46.62336877413770);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.578456948442600, -46.62337877413770);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.578476948442600, -46.62338877413770);
      _malas.add(_ramdom);
      _ramdom = LatLng(-23.578476948442600, -46.62339877413770);
      _malas.add(_ramdom);
      _currMala = _ramdom;
    });

    // print("Mala");
  }
}

saveLocationData(double latitude, double longitude) {
  CollectionReference locations = FirebaseFirestore.instance
      .collection('locations')
      .doc('celular')
      .collection('historico');

  return locations
      .add({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp()
      })
      .then((value) => print('Location data added'))
      .catchError((error) => print('Failed to add location data: $error'));
}
