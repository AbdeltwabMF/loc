import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

Future<void> writeData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  // Write reminders
  await boxReminders.put('len', appStates.reminderAll().length);
  for (int i = 0; i < appStates.reminderAll().length; ++i) {
    await boxReminders.put(i, appStates.reminderRead(index: i)!);
  }

  // Write favorites
  await boxFavorites.put('len', appStates.favoriteAll().length);
  for (int i = 0; i < appStates.favoriteAll().length; ++i) {
    await boxFavorites.put(i, appStates.favoriteRead(i)!);
  }

  // Write preferences
  await boxPreferences.put('pre-notify', appStates.notify);
  await boxPreferences.put('pre-themeMode', appStates.themeMode);
}

Future<void> readData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  // Read reminders
  final remindersLen = boxReminders.get('len', defaultValue: 0);
  for (int i = 0; i < remindersLen; ++i) {
    appStates.reminderAdd(boxReminders.get(i));
  }

  // Read favorites
  final favoritesLen = boxFavorites.get('len', defaultValue: 0);
  for (int i = 0; i < favoritesLen; ++i) {
    appStates.favoriteAdd(boxFavorites.get(i));
  }
  // Read settings
  appStates.setNotify(boxPreferences.get('pre-notify', defaultValue: true));
  appStates.setThemeMode(
      boxPreferences.get('pre-themeMode', defaultValue: 'System'));
}
