import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

class FavPlacesPage extends StatelessWidget {
  const FavPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Favorite Places',
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: appStates.favoriteAll().length,
          addAutomaticKeepAlives: true,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              dense: true,
              leading: const Icon(
                Icons.favorite_rounded,
                size: 32,
              ),
              subtitle: Text(
                '${appStates.favoriteAll()[index].position.latitude}, ${appStates.favoriteAll()[index].position.longitude}',
                style: const TextStyle(
                  fontFamily: 'Fantasque',
                ),
              ),
              title: Text(
                '${appStates.favoriteAll()[index].displayName}',
                style: const TextStyle(
                  fontFamily: 'NotoArabic',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
