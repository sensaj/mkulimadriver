// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mkulimadriver/services/auth_services.dart';
import 'package:mkulimadriver/services/local_services.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/restart_app_widget.dart';

class LogoutPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * .15,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to log out?",
              style:
                  TextStyle(color: colors.warning, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    "No",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                TextButton(
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    local
                        .setInstance(key: "hasLogin", type: bool, value: false)
                        .then((value) => Navigator.pop(context));
                    local.removeInstance(key: "driverData");
                    RestartWidget.restartApp(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
