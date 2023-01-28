import 'package:flutter/material.dart';
import 'package:loc/screen/home.dart';
import 'package:loc/style/colors.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

void main() {
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
          fontFamily: 'Fantasque',
          splashColor: AppColors.fg,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
