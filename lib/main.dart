import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/pages/home.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For older browsers and devices trust Let’s Encrypt certificates.
  // For more information: https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  // Initialize hive databases
  await Hive.initFlutter('loc_db');

  Hive.registerAdapter<Reminder>(ReminderAdapter());
  Hive.registerAdapter<Place>(PlaceAdapter());
  Hive.registerAdapter<Point>(PointAdapter());

  boxStates = await Hive.openBox('states');
  boxPreferences = await Hive.openBox('settings');

  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStates>(
      create: (context) => AppStates(),
      child: const Loc(),
    );
  }
}

class Loc extends StatelessWidget {
  const Loc({super.key});

  ThemeMode mode(int state) {
    switch (state) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LocThemeData.lightThemeData,
      darkTheme: LocThemeData.darkThemeData,
      themeMode: mode(appStates.themeMode),
      home: const HomePage(),
    );
  }
}
