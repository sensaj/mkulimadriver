// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/theme/colors.dart';

class CustomMarker extends StatelessWidget {
  final ClientRequest request;
  CustomMarker({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.house_alt,
              color: CupertinoColors.systemGrey3, size: 15),
          Card(
            margin: EdgeInsets.all(1),
            child: Container(
              width: 60,
              padding: EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(1),
              ),
              child: Text(
                "${request.start}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: CupertinoColors.white, fontSize: 11),
              ),
            ),
          )
        ],
      ),
    );
  }
}
