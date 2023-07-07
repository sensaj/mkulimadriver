// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/services/helper_services.dart';
import 'package:mkulimadriver/services/user_services.dart';
import 'package:mkulimadriver/theme/colors.dart';

class JourneyRequestContainer extends StatefulWidget {
  final ClientRequest request;
  final int total;
  const JourneyRequestContainer({required this.request, required this.total});

  @override
  State<JourneyRequestContainer> createState() =>
      _JourneyRequestContainerState();
}

class _JourneyRequestContainerState extends State<JourneyRequestContainer> {
  late ClientRequest request;
  User? sender, receiver;
  bool isLoading = true, isUpdating = false;
  @override
  void initState() {
    super.initState();
    request = widget.request;
    _getClientsInfo();
  }

  _getClientsInfo() async {
    final _sender = await userServices.getClientData(userId: request.sender);
    final _receiver =
        await userServices.getClientData(userId: request.receiver);
    setState(() {
      sender = _sender;
      receiver = _receiver;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: colors.darkBlue, offset: Offset(0, 4), blurRadius: 5.0)
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(5),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sender Info",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Text(
                            "${sender!.name}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${widget.request.start}"),
                          Text("${widget.request.parcel}"),
                          SizedBox(height: 10),
                          Wrap(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: colors.darkBlue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(3),
                                    ),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.phone,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  helper.makeOutAppCommunication(
                                      media: "call",
                                      comuItem: "${sender!.phone}",
                                      context: context);
                                },
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(3),
                                    ),
                                  ),
                                  child: Icon(CupertinoIcons.text_bubble,
                                      color: Colors.white),
                                ),
                                onTap: () {
                                  helper.makeOutAppCommunication(
                                      media: "sms",
                                      comuItem: "${sender!.phone}",
                                      context: context);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Receiver Info",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Text(
                            "${receiver!.name}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${widget.request.destination}"),
                          Text("${widget.request.parcel}"),
                          SizedBox(height: 10),
                          Wrap(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: colors.darkBlue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(3),
                                    ),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.phone,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  helper.makeOutAppCommunication(
                                      media: "call",
                                      comuItem: "${receiver!.phone}",
                                      context: context);
                                },
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(3),
                                      topRight: Radius.circular(3),
                                    ),
                                  ),
                                  child: Icon(CupertinoIcons.text_bubble,
                                      color: Colors.white),
                                ),
                                onTap: () {
                                  helper.makeOutAppCommunication(
                                      media: "sms",
                                      comuItem: "${receiver!.phone}",
                                      context: context);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  isUpdating
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 1),
                        )
                      : InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(color: colors.primary),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          onTap: () {
                            _submitParcel();
                          },
                        )
                ],
              ),
      ),
    );
  }

  _submitParcel() async {
    setState(() {
      isUpdating = true;
    });
    try {
      DocumentReference requestDoc = FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id);

      await requestDoc.update({'status': 'submitted'});
      if (widget.total <= 1) {
        DocumentReference requestDoc = FirebaseFirestore.instance
            .collection('schedules')
            .doc(widget.request.schedule);

        await requestDoc.update({'status': 'completed'});
      }
      Navigator.pop(context);
      print('Document updated successfully');
    } catch (e) {
      print('Error: $e');
    }
    if (mounted) {
      setState(() {
        isUpdating = false;
      });
    }
  }
}

class RequestContainer extends StatefulWidget {
  final ClientRequest request;
  const RequestContainer({required this.request});

  @override
  State<RequestContainer> createState() => _RequestContainerState();
}

class _RequestContainerState extends State<RequestContainer> {
  late ClientRequest request;
  User? sender, receiver;
  bool isLoading = true, isUpdating = false;
  @override
  void initState() {
    super.initState();
    request = widget.request;
    _getClientsInfo();
  }

  _getClientsInfo() async {
    print(widget.request.sender);
    final _sender = await userServices.getClientData(userId: request.sender);
    final _receiver =
        await userServices.getClientData(userId: request.receiver);
    setState(() {
      sender = _sender;
      receiver = _receiver;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(5),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sender Info",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Text(
                          "${sender!.name}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("${widget.request.start}"),
                        Text("${widget.request.parcel}"),
                        Wrap(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: colors.darkBlue,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.phone,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {},
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(3),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                ),
                                child: Icon(CupertinoIcons.text_bubble,
                                    color: Colors.white),
                              ),
                              onTap: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Receiver Info",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Text(
                          "${receiver!.name}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("${widget.request.destination}"),
                        Text("${widget.request.parcel}"),
                        SizedBox(height: 30)
                        // Wrap(
                        //   children: [
                        //     InkWell(
                        //       borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(3),
                        //         topRight: Radius.circular(3),
                        //       ),
                        //       child: Container(
                        //         padding: EdgeInsets.symmetric(
                        //             vertical: 3, horizontal: 5),
                        //         decoration: BoxDecoration(
                        //           color: colors.darkBlue,
                        //           borderRadius: BorderRadius.only(
                        //             topLeft: Radius.circular(3),
                        //             topRight: Radius.circular(3),
                        //           ),
                        //         ),
                        //         child: Icon(
                        //           CupertinoIcons.phone,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //     SizedBox(width: 10),
                        //     InkWell(
                        //       borderRadius: BorderRadius.only(
                        //         topLeft: Radius.circular(3),
                        //         topRight: Radius.circular(3),
                        //       ),
                        //       child: Container(
                        //         padding: EdgeInsets.symmetric(
                        //             vertical: 3, horizontal: 5),
                        //         decoration: BoxDecoration(
                        //           color: colors.primary,
                        //           borderRadius: BorderRadius.only(
                        //             topLeft: Radius.circular(3),
                        //             topRight: Radius.circular(3),
                        //           ),
                        //         ),
                        //         child: Icon(CupertinoIcons.text_bubble,
                        //             color: Colors.white),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ],
                ),
                Divider(),
                isUpdating
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 8),
                              decoration: BoxDecoration(color: Colors.red),
                              child: Text(
                                "Reject",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            onTap: () {
                              _rejectRequest();
                            },
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 8),
                              decoration: BoxDecoration(color: colors.primary),
                              child: Text(
                                "Accept",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            onTap: () {
                              _acceptRequest();
                            },
                          ),
                        ],
                      )
              ],
            ),
    );
  }

  _rejectRequest() async {
    setState(() {
      isUpdating = true;
    });
    try {
      DocumentReference requestDoc = FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id);

      await requestDoc.update({'status': 'rejected'});

      print('Document updated successfully');
    } catch (e) {
      print('Error: $e');
    }
    if (mounted) {
      setState(() {
        isUpdating = false;
      });
    }
  }

  _acceptRequest() async {
    setState(() {
      isUpdating = true;
    });
    try {
      DocumentReference requestDoc = FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.id);

      await requestDoc.update({'status': 'accepted'});

      print('Document updated successfully');
    } catch (e) {
      print('Error: $e');
    }
    if (mounted) {
      setState(() {
        isUpdating = false;
      });
    }
  }
}
