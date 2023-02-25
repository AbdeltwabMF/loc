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
  late LatLng _currentPosition;

  bool notify = true;
  bool ringing = false;
  bool listening = false;
  bool arrived = false;
  ThemeMode _themeMode = ThemeMode.system;

  Reminder? readReminder(int index) {
    if (index >= _reminders.length || index < 0) return null;
    return _reminders[index];
  }

  void createReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    final index = _reminders.indexWhere((element) => element.id == reminder.id);
    if (index == -1) return;
    _reminders[index] = reminder;
    notifyListeners();
  }

  void deleteReminder(int index) {
    if (index >= _reminders.length || index < 0) return;
    _reminders.removeAt(index);
    notifyListeners();
  }

  List<Reminder> readAllReminders() {
    return _reminders;
  }

  void deleteAllReminders() {
    _reminders.clear();
  }

  void addFavPlace(Place place) {
    _favoritPlaces.add(place);
    notifyListeners();
  }

  void deleteFavPlace(int index) {
    if (index >= _favoritPlaces.length || index < 0) return;
    _favoritPlaces.removeAt(index);
    notifyListeners();
  }

  void deleteAllFavPlaces() {
    _favoritPlaces.clear();
  }

  List<Place> readAllFavPlaces() {
    return _favoritPlaces;
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

  void setArrived(bool state) {
    arrived = state;
    notifyListeners();
  }

  void setListening(bool state) {
    listening = state;
    notifyListeners();
  }

  void setThemeMode(ThemeMode state) {
    _themeMode = state;
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    return _themeMode;
  }
}
