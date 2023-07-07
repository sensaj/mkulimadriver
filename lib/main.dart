import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/app.dart';
import 'package:mkulimadriver/widgets/restart_app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RestartWidget(child: Mkulima()));
}
