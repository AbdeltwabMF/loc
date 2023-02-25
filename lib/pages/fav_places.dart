import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

class FavPlacesScreen extends StatelessWidget {
  const FavPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Favorite Places',
        ),
      ),
      body: const SafeArea(
        child: Text('Hola'),
      ),
    );
  }
}
