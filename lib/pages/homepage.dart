// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/pages/schedule_journey.dart';
import 'package:mkulimadriver/providers/map_view_provider.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/driver_info_card.dart';
import 'package:mkulimadriver/widgets/logout_prompt.dart';
import 'package:mkulimadriver/widgets/request_container.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  final User user;
  Homepage({required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        drawer: _driverDrawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 300,
              iconTheme: IconThemeData(color: colors.primary),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: size.width * .03),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: DriverInfoCard(user: widget.user),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  vertical: 10, horizontal: size.width * .03),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      "Requests",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    Divider(color: CupertinoColors.systemGrey5),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('schedules')
                          .where("driver_id", isEqualTo: widget.user.id!)
                          .where("status", isEqualTo: "active")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 400,
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(strokeWidth: 1),
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isNotEmpty) {
                            return _requestInfoWidget(
                                snapshot.data!.docs.first.id);
                          }
                          return Container(
                            alignment: Alignment.center,
                            height: 400,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sentiment_neutral,
                                  color: CupertinoColors.systemGrey,
                                  size: 41,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "No new schedules",
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        return Container(
                          height: 400,
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder _requestInfoWidget(scheduleId) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('requests')
          .where("schedule_id", isEqualTo: scheduleId)
          .where("status", isEqualTo: "sent")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 400,
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(strokeWidth: 1),
            ),
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isNotEmpty) {
            return SizedBox(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                primary: false,
                itemBuilder: (BuildContext context, int index) {
                  final data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  data['id'] = snapshot.data!.docs[index].id;
                  final request = ClientRequest.fromMap(data);
                  return RequestContainer(request: request);
                },
              ),
            );
          }

          return Container(
            alignment: Alignment.center,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_neutral,
                  color: CupertinoColors.systemGrey,
                  size: 41,
                ),
                SizedBox(height: 10),
                Text(
                  "No new requests for the next schedule",
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          );
        }
        return Container(
          height: 400,
          alignment: Alignment.center,
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(strokeWidth: 1),
          ),
        );
      },
    );
  }

  Drawer _driverDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary),
              ),
              child: Icon(
                CupertinoIcons.person_alt,
                color: colors.primary,
                size: 100,
              ),
            ),
            Text(
              "${widget.user.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.darkBlue,
                fontSize: 18,
              ),
            ),
            Text(
              "${widget.user.phone}",
              style: TextStyle(color: colors.darkBlue, fontSize: 12),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Truck name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${widget.user.truck}",
                      style: TextStyle(
                        color: colors.darkBlue,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Plate No.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${widget.user.plateNo}",
                      style: TextStyle(color: colors.darkBlue),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Licence",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "${widget.user.licence}",
                      style: TextStyle(color: colors.darkBlue),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            InkWell(
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  "Log Out",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              onTap: () {
                showModalBottomSheet<dynamic>(
                  isScrollControlled: true,
                  clipBehavior: Clip.antiAlias,
                  backgroundColor: Color(0xffe5e4e2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  )),
                  elevation: 5,
                  context: context,
                  builder: (context) => LogoutPrompt(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
