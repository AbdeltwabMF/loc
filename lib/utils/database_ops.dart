import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:provider/provider.dart';

Future<void> writeData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  // Write reminders
  await boxStates.put('reminders', appStates.reminderAll());

  // Write favorites
  await boxStates.put('favorites', appStates.favoriteAll());

  // Write preferences
  await boxPreferences.put('pre-notify', appStates.notify);
  await boxPreferences.put('pre-themeMode', appStates.themeMode);
}

Future<void> readData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  // Read reminders
  appStates.reminderAddAll(
    List<Reminder>.from(
      boxStates.get('reminders')?.map(
            (e) => Reminder.fromJson(e),
          ),
    ),
  );

  // Read favorites
  appStates.favoriteAddAll(
    List<Place>.from(
      boxStates.get('favorites')?.map(
            (e) => Place.fromJson(e),
          ),
    ),
  );

  // Read settings
  appStates.setNotify(boxPreferences.get('pre-notify') as bool);
  appStates.setThemeMode(boxPreferences.get('pre-themeMode') as int);
}
