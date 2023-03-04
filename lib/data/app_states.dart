import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/reminder.dart';

late StreamSubscription<Position> positionStream;

class AppStates extends ChangeNotifier {
  final _reminders = <Reminder>[];
  final _favoritPlaces = <Place>[];
  final _arrival = <String>{};

  late LatLng _currentPosition;

  bool notify = true;
  bool ringing = false;
  bool listening = false;

  ThemeMode themeMode = ThemeMode.system;

  bool reminderOptions = false;
  int selected = 0;
  int bottomNavBarIndex = 0;

  Reminder? reminderRead(int index) {
    if (index >= _reminders.length || index < 0) return null;
    return _reminders[index];
  }

  void reminderAdd(Reminder reminder) {
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

  List<Reminder> reminderAll() {
    return _reminders;
  }

  void reminderClear() {
    _reminders.clear();
  }

  Reminder? reminderFromId(String id) {
    return _reminders.firstWhere((element) => element.id == id);
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

  void arrivalAdd(String id) {
    _arrival.add(id);
    notifyListeners();
  }

  void arrivalDelete(String id) {
    _arrival.remove(id);
    notifyListeners();
  }

  void arrivalClear() {
    _arrival.clear();
  }

  Set<String> arrivalAll() {
    return _arrival;
  }

  void setCurrent(LatLng current) {
    _currentPosition = current;
    notifyListeners();
  }

  LatLng getCurrent() {
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

  void setThemeMode(ThemeMode mode) {
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
}
