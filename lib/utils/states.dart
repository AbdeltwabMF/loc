import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loc/utils/types.dart';

late StreamSubscription<Position> positionStream;

class AppStates extends ChangeNotifier {
  final _reminders = <Reminder>[];
  final _favoritPlaces = <Place>[];
  late LatLong _current;

  TextEditingController title = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController radius = TextEditingController(text: '1000');
  bool withAlarm = true;
  TextEditingController notes = TextEditingController();

  bool isRinging = false;

  void setCurrent(LatLong current) {
    _current = current;
    notifyListeners();
  }

  LatLong getCurrent() {
    return _current;
  }

  void addFavPlace(Place place) {
    _favoritPlaces.add(place);
    notifyListeners();
  }

  void removeFavPlace(int index) {
    _favoritPlaces.removeAt(index);
    notifyListeners();
  }

  List<Place> readAllFavPlaces() {
    return _favoritPlaces;
  }

  void setIsRinging(bool state) {
    isRinging = state;
    notifyListeners();
  }

  Reminder? readReminder(int index) {
    if (index >= _reminders.length || index < 0) return null;
    return _reminders[index];
  }

  List<Reminder> readAllReminders() {
    return _reminders;
  }

  void createReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    for (int i = 0; i < _reminders.length; ++i) {
      if (_reminders[i].id == reminder.id) {
        _reminders[i] = reminder;
        notifyListeners();
        return;
      }
    }
  }

  void deleteReminder(int index) {
    _reminders.removeAt(index);
    notifyListeners();
  }

  void setTitle(String title) {
    this.title.value = this.title.value.copyWith(text: title);
    notifyListeners();
  }

  void setLatitude(String latitude) {
    this.latitude.value = this.latitude.value.copyWith(text: latitude);
    notifyListeners();
  }

  void setLongitude(String longitude) {
    this.longitude.value = this.longitude.value.copyWith(text: longitude);
    notifyListeners();
  }

  void setRadius(String radius) {
    this.radius.value = this.radius.value.copyWith(text: radius);
    notifyListeners();
  }

  void setWithAlarm(bool state) {
    withAlarm = state;
    notifyListeners();
  }

  void setNotes(String notes) {
    this.notes.value = this.notes.value.copyWith(text: notes);
    notifyListeners();
  }

  void clear() {
    title.clear();
    latitude.clear();
    longitude.clear();
    withAlarm = true;
    setRadius('1000');
    notes.clear();

    notifyListeners();
  }
}
