// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/providers/map_view_provider.dart';
import 'package:mkulimadriver/widgets/app_elevated_button.dart';
import 'package:mkulimadriver/widgets/custom_marker/custom_marker_builder.dart';

class MapView extends StatefulWidget {
  final DriverSchedule schedule;
  final MapViewProvider mapState;
  final List<ClientRequest> requests;
  MapView(
      {required this.schedule, required this.mapState, required this.requests});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _initialPosition;
  late Timer timer;
  late MapViewProvider mapState;
  @override
  void initState() {
    super.initState();
    mapState = widget.mapState;
    mapState.startJourney(widget.schedule, context);
    Future.delayed(
      Duration(seconds: 5),
      () {
        mapState.initMap(widget.requests);
      },
    );
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await mapState.updateUserPositionOnMap(widget.schedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height - 170,
      alignment: Alignment.center,
      child: mapState.isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Preparing map...",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            )
          : mapState.mapErrors != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sentiment_neutral,
                      color: CupertinoColors.systemRed,
                      size: 41,
                    ),
                    Text(
                      mapState.mapErrors!['header'],
                      style: TextStyle(
                        color: CupertinoColors.systemRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      mapState.mapErrors!['msg'],
                      style: TextStyle(
                          color: CupertinoColors.systemRed, fontSize: 13),
                    ),
                    SizedBox(
                      width: 200,
                      child: AppElevatedButton(
                        label: "Retry",
                        onPressed: () {
                          mapState.determinePosition(context);
                        },
                      ),
                    ),
                  ],
                )
              : GoogleMap(
                  initialCameraPosition: mapState.initialCameraPosition,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  markers: mapState.markers,
                  onMapCreated: mapState.onCreated,
                ),
      // CustomGoogleMapMarkerBuilder(
      //     customMarkers: mapState.markers,
      //     builder: (BuildContext context, Set<Marker>? markers) {
      //       if (markers == null) {
      //         return Center(
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               SizedBox(
      //                 width: 30,
      //                 height: 30,
      //                 child: CircularProgressIndicator(
      //                     color: Colors.white),
      //               ),
      //               SizedBox(height: 10),
      //               Text(
      //                 "Preparing map markers...",
      //                 style: TextStyle(color: Colors.white),
      //               )
      //             ],
      //           ),
      //         );
      //       }
      //       return GoogleMap(
      //         initialCameraPosition: mapState.initialCameraPosition,
      //         myLocationButtonEnabled: true,
      //         myLocationEnabled: true,
      //         compassEnabled: true,
      //         markers: markers,
      //         onMapCreated: mapState.onCreated,
      //       );
      //     },
      //   ),
    );
  }
}
