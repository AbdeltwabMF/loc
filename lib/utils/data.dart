import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

Future<void> writeData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  // Write reminders
  await boxReminders.put('reminderLength', appStates.reminderAll().length);
  for (int i = 0; i < appStates.reminderAll().length; ++i) {
    await boxReminders.put(i, appStates.reminderRead(i)!);
  }

  // Write favorites
  await boxFavorites.put('favoriteLength', appStates.favoriteAll().length);
  for (int i = 0; i < appStates.favoriteAll().length; ++i) {
    await boxFavorites.put(i, appStates.favoriteAll().elementAt(i));
  }

  // Write settings
  await boxSettings.put('notify', appStates.notify);
  final themeMode = appStates.themeMode;
  switch (themeMode) {
    case ThemeMode.system:
      await boxSettings.put('themeMode', 0);
      break;
    case ThemeMode.dark:
      await boxSettings.put('themeMode', 1);
      break;
    case ThemeMode.light:
      await boxSettings.put('themeMode', 2);
      break;
    default:
      break;
  }
}

Future<void> readData(BuildContext context) async {
  final appStates = Provider.of<AppStates>(context, listen: false);

  boxReminders = await Hive.openBox('reminders');
  boxFavorites = await Hive.openBox('favorites');
  boxSettings = await Hive.openBox('settings');

  // Read reminders
  int length = await boxReminders.get('reminderLength');
  for (int i = 0; i < length; ++i) {
    appStates.reminderAdd(boxReminders.get(i));
  }

  // Read favorites
  length = await boxFavorites.get('favoriteLength');
  for (int i = 0; i < length; ++i) {
    appStates.favoriteAdd(boxFavorites.get(i));
  }

  // Read settings
  appStates.setNotify(boxSettings.get('notify') ?? true);

  final themeMode = boxSettings.get('themeMode');

  switch (themeMode) {
    case 0:
      appStates.setThemeMode(ThemeMode.system);
      break;
    case 1:
      appStates.setThemeMode(ThemeMode.dark);
      break;
    case 2:
      appStates.setThemeMode(ThemeMode.light);
      break;
    default:
      break;
  }
}
