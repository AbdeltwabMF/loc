import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';

late StreamSubscription<Position> positionStream;

// Hive boxes
late Box boxStates;
late Box boxPreferences;

class AppStates extends ChangeNotifier {
  // States
  List<Reminder> _reminders = <Reminder>[];
  List<Place> _favoritPlaces = <Place>[];

  // Preferences
  bool notify = true;
  int themeMode = 0;

  // Does not matter, just Set to default on start
  late Point _currentPosition;

  bool ringing = false;
  bool listening = false;

  bool loaded = false;
  bool reminderOptions = false;
  int selected = -1;
  int bottomNavBarIndex = 0;

  Reminder? reminderRead(int index) {
    if (index >= _reminders.length || index < 0) return null;
    return _reminders[index];
  }

  void reminderAdd(Reminder reminder) {
    final index = _reminders.indexWhere((element) => element.id == reminder.id);
    if (index != -1) return;
    _reminders.add(reminder);
    notifyListeners();
  }

  void reminderUpdate(Reminder reminder) {
    final index = _reminders.indexWhere((element) => element.id == reminder.id);
    if (index == -1) return;
    _reminders[index] = reminder;
    notifyListeners();
  }

  void reminderDelete(int index) {
    if (index >= _reminders.length || index < 0) return;
    _reminders.removeAt(index);
    notifyListeners();
  }

  List<Reminder> arrivalAll() {
    return _reminders
        .where((element) =>
            element.isArrived == true && element.isTracking == true)
        .toList();
  }

  List<Reminder> reminderAll() {
    return _reminders;
  }

  void reminderAddAll(List<Reminder> reminders) {
    _reminders = reminders;
    notifyListeners();
  }

  void reminderClear() {
    _reminders.clear();
  }

  void favoriteAdd(Place place) {
    if (_favoritPlaces.contains(place) == false) {
      _favoritPlaces.add(place);
      notifyListeners();
    }
  }

  void favoriteDelete(int index) {
    if (index >= _favoritPlaces.length || index < 0) return;
    _favoritPlaces.removeAt(index);
    notifyListeners();
  }

  void favoriteClear() {
    _favoritPlaces.clear();
  }

  List<Place> favoriteAll() {
    return _favoritPlaces;
  }

  void favoriteAddAll(List<Place> places) {
    _favoritPlaces = places;
    notifyListeners();
  }

  void setCurrent(Point current) {
    _currentPosition = current;
    notifyListeners();
  }

  Point getCurrent() {
    return _currentPosition;
  }

  void setRinging(bool state) {
    ringing = state;
    notifyListeners();
  }

  void setNotify(bool state) {
    notify = state;
    notifyListeners();
  }

  void setListening(bool state) {
    listening = state;
    notifyListeners();
  }

  void setThemeMode(int mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setBottomNavBarIndex(int index) {
    bottomNavBarIndex = index;
    notifyListeners();
  }

  void setReminderOptions(bool state) {
    reminderOptions = state;
    notifyListeners();
  }

  void setSelected(int index) {
    selected = index;
    notifyListeners();
  }

  void setLoaded(bool state) {
    loaded = state;
    notifyListeners();
  }
}
