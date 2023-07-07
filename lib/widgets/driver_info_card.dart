// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/pages/journey/journey_view_page.dart';
import 'package:mkulimadriver/pages/schedule_journey.dart';
import 'package:mkulimadriver/providers/map_view_provider.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:provider/provider.dart';

class DriverInfoCard extends StatefulWidget {
  final User user;
  DriverInfoCard({required this.user});

  @override
  State<DriverInfoCard> createState() => _DriverInfoCardState();
}

class _DriverInfoCardState extends State<DriverInfoCard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('schedules')
          .where("driver_id", isEqualTo: widget.user.id!)
          .where("status", whereIn: ["active", "started"]).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isNotEmpty) {
            final data =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;
            data['id'] = snapshot.data!.docs.first.id;
            final schedule = DriverSchedule.fromMap(data);
            return Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: colors.darkBlue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Schedule on ${schedule.beautyDate}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.darkBlue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScheduleJourneyPage(
                                      user: widget.user, schedule: schedule),
                                ));
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(color: CupertinoColors.systemGrey5),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.map_pin,
                            color: CupertinoColors.systemGrey3,
                            size: 15,
                          ),
                          Text(
                            "${schedule.start}",
                            style: TextStyle(
                              color: CupertinoColors.systemGrey3,
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.map,
                            color: CupertinoColors.systemGrey3,
                            size: 15,
                          ),
                          Text(
                            "${schedule.via}",
                            style: TextStyle(
                              color: CupertinoColors.systemGrey3,
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.pin_fill,
                            color: CupertinoColors.systemGrey3,
                            size: 15,
                          ),
                          Text(
                            "${schedule.destination}",
                            style: TextStyle(
                              color: CupertinoColors.systemGrey3,
                            ),
                          )
                        ],
                      ),
                      Divider(color: CupertinoColors.systemGrey5),
                      SizedBox(height: 30),
                      Center(
                        child: _requestInfoWidget(schedule: schedule),
                      )
                    ],
                  )
                ],
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: colors.darkBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_month, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScheduleJourneyPage(user: widget.user),
                    ));
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  StreamBuilder _requestInfoWidget({required DriverSchedule schedule}) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('requests')
          .where("schedule_id", isEqualTo: schedule.id)
          .where("status", isEqualTo: "accepted")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isNotEmpty) {
            final List<ClientRequest> requests = [];
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = snapshot.data!.docs.first.id;
              final request = ClientRequest.fromMap(data);
              requests.add(request);
            }
            return ElevatedButton(
              child: Text(schedule.status == "started" ? "Continue" : "Start"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JourneyViewPage(
                        requests: requests,
                        schedule: schedule,
                        user: widget.user,
                        // mapState: mapState,
                      ),
                    ));
              },
            );
          }

          return Container();
        }
        return Container();
      },
    );
  }
}
