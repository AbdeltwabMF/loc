import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loc - Location-based reminder',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Loc'),
        ),
        body: const Text(
          'Hi, there',
        ),
      ),
    );
  }
}
