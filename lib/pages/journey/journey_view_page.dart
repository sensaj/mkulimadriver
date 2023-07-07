// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/pages/journey/map_view.dart';
import 'package:mkulimadriver/providers/map_view_provider.dart';
import 'package:mkulimadriver/services/helper_services.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/request_container.dart';
import 'package:provider/provider.dart';

class JourneyViewPage extends StatefulWidget {
  final User user;
  final DriverSchedule schedule;
  final List<ClientRequest> requests;
  JourneyViewPage(
      {required this.requests, required this.schedule, required this.user});

  @override
  State<JourneyViewPage> createState() => _JourneyViewPageState();
}

class _JourneyViewPageState extends State<JourneyViewPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DriverSchedule schedule;
  String today = "";

  @override
  void initState() {
    super.initState();
    schedule = widget.schedule;
    today = helper.beautifyDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mapState = Provider.of<MapViewProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        body: SizedBox(
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.darkBlue,
                          ),
                          child: IconButton(
                            icon: Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Text(
                          "Journey to: ${schedule.destination}",
                          style: TextStyle(
                            color: colors.darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              today,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.darkBlue,
                                fontSize: 16,
                              ),
                            ),
                            // Text(
                            //   currentTime,
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     color: colors.darkBlue,
                            //   ),
                            // ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Current Location",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.darkBlue,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              mapState.currentLocName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        _requestInfoWidget(),
                      ],
                    )
                  ],
                ),
              ),
              MapView(
                  schedule: schedule,
                  mapState: mapState,
                  requests: widget.requests),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder _requestInfoWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('requests')
          .where("schedule_id", isEqualTo: schedule.id)
          .where("status", isEqualTo: "accepted")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return SizedBox(height: 48.3);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(height: 48.3);
        }
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isNotEmpty) {
            final List<ClientRequest> _requests = [];
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              final request = ClientRequest.fromMap(data);
              _requests.add(request);
            }

            return Container(
              decoration:
                  BoxDecoration(color: colors.primary, shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(CupertinoIcons.cube_box, color: Colors.white),
                onPressed: () {
                  _showClientInfoSheet(_requests);
                },
              ),
            );
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Icon(Icons.sentiment_very_satisfied, color: Colors.white),
                Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          );
        }
        return SizedBox(height: 48.3);
      },
    );
  }

  void _showClientInfoSheet(List<ClientRequest> requests) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 200,
          child: ListView.builder(
            itemCount: requests.length,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return JourneyRequestContainer(
                request: requests[index],
                total: requests.length,
              );
            },
          ),
        );
      },
    );
  }
}
