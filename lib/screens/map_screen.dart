// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmybag/services/location_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
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

  @override
  void initState() {
    super.initState();
    _locationClient.init();
    _listenLocation();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _listenLocation();
      //_getMalas();
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
                              builder: (context) => const Icon(Icons.person),
                            ),
                          ],
                        ),
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
                                    'Última localidade:',
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
                                    text: 'Bagagem',
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  AppText(
                                    text: '123',
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

    final _posicoesCollection =
        malasCollection.doc(malasCollection.id).collection('logs').limit(1);
    // _currMala = LatLng(_posicoesCollection.snapshots()['latitute'],
    //     _posicoesCollection['latitute'].toString());
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

// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:findmybag/services/location_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// import '../widgets/app_text.dart';

// class MapScreen extends StatefulWidget {
//   static const id = 'map_screen.dart';
//   const MapScreen({
//     super.key,
//   });

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
//   final _locationClient = LocationClient();
//   final _mapController = MapController();
//   final _points = <LatLng>[];
//   final _malas = <LatLng>[];
//   LatLng? _currMala;
//   LatLng? _currPosition;
//   LatLng? _currPositionAnt;
//   bool _isServiceRunning = false;

//   @override
//   void initState() {
//     super.initState();
//     _locationClient.init();
//     _listenLocation();
//     Timer.periodic(const Duration(seconds: 3), (timer) {
//       _listenLocation();
//       _getMalas();
//       // _calculateDistance();
//     });
//   }

//   void _listenLocation() async {
//     if (!_isServiceRunning && await _locationClient.isServiceEnabled()) {
//       _isServiceRunning = true;
//       _locationClient.locationStream.listen((event) async {
//         setState(() {
//           _currPosition = event;
//         });
//         _points.add(_currPosition!);
//         if (_currPositionAnt != _currPosition) {
//           _currPositionAnt = _currPosition;
//           await saveLocationData(
//               _currPosition!.latitude, _currPosition!.longitude);
//         }
//       });
//     } else {
//       _isServiceRunning = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     TabController _tabController = TabController(length: 3, vsync: this);
//     return Scaffold(
//       body: Center(child: LayoutBuilder(builder: (context, _) {
//         return _currPosition == null
//             ? const CircularProgressIndicator()
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 500,
//                     width: double.maxFinite,
//                     // margin: const EdgeInsets.only(top: 60, right: 20, left: 20),
//                     child: FlutterMap(
//                       mapController: _mapController,
//                       options: MapOptions(
//                         center: _currPosition,
//                         zoom: 18,
//                       ),
//                       children: [
//                         TileLayer(
//                           urlTemplate:
//                               'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           userAgentPackageName: 'com.example.app',
//                         ),
//                         PolylineLayer(
//                           polylineCulling: false,
//                           polylines: [
//                             Polyline(
//                               points: _points,
//                               color: Colors.blue,
//                               strokeWidth: 4,
//                             ),
//                           ],
//                         ),
//                         if (_currPosition != null)
//                           MarkerLayer(
//                             markers: [
//                               Marker(
//                                 point: _currPosition!,
//                                 builder: (context) => const Icon(Icons.person),
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                      Container(
//             height: 200,
//             width: double.maxFinite,
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, top: 20),
//                   child: Container(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.blue,
//                         ),
//                         SizedBox(width: 5),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(
//                               text: 'Teste',
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             AppText(
//                               text: '123',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, top: 20),
//                   child: Container(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.blue,
//                         ),
//                         SizedBox(width: 5),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(
//                               text: 'Bagagem',
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             AppText(
//                               text: '123',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20, top: 20),
//                   child: Container(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.blue,
//                         ),
//                         SizedBox(width: 5),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(
//                               text: 'aaa',
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             AppText(
//                               text: '123',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 ],
//               )
                           
//       })),
//     );
//   }

//   void _getMalas() {
//     final CollectionReference malasCollection = FirebaseFirestore.instance
//         .collection('locations')
//         .doc('mala')
//         .collection('rastreamento');

//     final _posicoesCollection =
//         malasCollection.doc(malasCollection.id).collection('logs').limit(1);
//     // _currMala = LatLng(_posicoesCollection.snapshots()['latitute'],
//     //     _posicoesCollection['latitute'].toString());
//   }
// }

// saveLocationData(double latitude, double longitude) {
//   CollectionReference locations = FirebaseFirestore.instance
//       .collection('locations')
//       .doc('celular')
//       .collection('historico');

//   return locations
//       .add({
//         'latitude': latitude,
//         'longitude': longitude,
//         'timestamp': FieldValue.serverTimestamp()
//       })
//       .then((value) => print('Location data added'))
//       .catchError((error) => print('Failed to add location data: $error'));
// }
