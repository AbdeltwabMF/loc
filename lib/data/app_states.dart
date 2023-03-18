import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';

late StreamSubscription<Position> positionStream;

// Hive boxes
late Box boxReminders;
late Box boxFavorites;
late Box boxPreferences;

class AppStates extends ChangeNotifier {
  // States
  List<Reminder> _reminders = <Reminder>[];
  List<Place> _favoritePlaces = <Place>[];
  List<String> _selected = <String>[];

  // Preferences
  bool notify = true;
  String themeMode = 'System';

  // Does not matter, just Set to default on start
  late Point _currentPosition;

  bool ringing = false;
  bool listening = false;

  bool loaded = false;
  int bottomNavBarIndex = 0;

  Reminder? reminderRead({int? index, String? id}) {
    if (index != null) {
      return _reminders[index];
    } else if (id != null) {
      for (int i = 0; i < _reminders.length; ++i) {
        if (_reminders[i].id == id) {
          return _reminders[i];
        }
      }
      return null;
    } else {
      return null;
    }
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

  void reminderDelete({int? index, String? id}) {
    if (index != null) {
      _reminders.removeAt(index);
    } else if (id != null) {
      for (int i = 0; i < _reminders.length; ++i) {
        if (_reminders[i].id == id) {
          _reminders.removeAt(i);
        }
      }
    } else {
      return;
    }
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
    if (_favoritePlaces.contains(place) == false) {
      _favoritePlaces.add(place);
      notifyListeners();
    }
  }

  Place? favoriteRead(int index) {
    if (index >= _favoritePlaces.length || index < 0) return null;
    return _favoritePlaces[index];
  }

  void favoriteDelete(int index) {
    if (index >= _favoritePlaces.length || index < 0) return;
    _favoritePlaces.removeAt(index);
    notifyListeners();
  }

  void favoriteClear() {
    _favoritePlaces.clear();
  }

  List<Place> favoriteAll() {
    return _favoritePlaces;
  }

  void favoriteAddAll(List<Place> places) {
    _favoritePlaces = places;
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

  void setThemeMode(String mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setBottomNavBarIndex(int index) {
    bottomNavBarIndex = index;
    notifyListeners();
  }

  void selectedAdd(String id) {
    _selected.add(id);
    notifyListeners();
  }

  void selectedDelete(String id) {
    _selected.removeWhere((element) => element == id);
    notifyListeners();
  }

  // check if specific reminder is selected using its index or id
  bool selectedRead({int? index, String? id}) {
    if (index != null) {
      final id = _reminders[index].id;
      for (int i = 0; i < _selected.length; ++i) {
        if (id == _selected[i]) {
          return true;
        }
      }
      return false;
    } else if (id != null) {
      for (int i = 0; i < _selected.length; ++i) {
        if (_selected[i] == id) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  void selectedClear() {
    _selected.clear();
    notifyListeners();
  }

  List<String> selectedAll() {
    return _selected;
  }

  void setLoaded(bool state) {
    loaded = state;
    notifyListeners();
  }
}
