import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/pages/auth/login_screen.dart';
import 'package:mkulimadriver/pages/auth/registration_screen.dart';
import 'package:mkulimadriver/pages/homepage.dart';
import 'package:mkulimadriver/providers/map_view_provider.dart';
import 'package:mkulimadriver/services/local_services.dart';
import 'package:provider/provider.dart';

class Mkulima extends StatefulWidget {
  Mkulima({Key? key}) : super(key: key);

  @override
  State<Mkulima> createState() => _MkulimaState();
}

class _MkulimaState extends State<Mkulima> {
  bool hasLogin = false;
  late User user;
  @override
  void initState() {
    super.initState();
    checkLocalData();
  }

  checkLocalData() async {
    final _hasLogin = await local.checkLoginState();
    if (_hasLogin) {
      final _user = await local.getLocalUserData();
      if (_user != null) {
        setState(() {
          user = _user;
          hasLogin = _hasLogin;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewProvider>(
            create: (_) => MapViewProvider(context)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: hasLogin ? Homepage(user: user) : LoginScreen(),
      ),
    );
  }
}
