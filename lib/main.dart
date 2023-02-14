import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/screens/about.dart';
import 'package:loc/screens/home.dart';
import 'package:loc/screens/new_reminder.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For older browsers and devices trust Let’s Encrypt certificates.
  // For more information: https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStates>(
      create: (context) => AppStates(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Quicksand',
          splashColor: AppColors.darkAqua,
          primaryColor: AppColors.darkBlue,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 56.0,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontSize: 28.0,
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
