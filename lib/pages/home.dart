import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/pages/reminders_page.dart';
import 'package:loc/pages/saved_places_page.dart';
import 'package:loc/pages/settings_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  late final StreamSubscription<Place> _geoIntentSubscription;

  static const _pages = <Widget>[
    RemindersPage(),
    SavedPlacesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _geoIntentSubscription = GeoUriService.places.listen(
      _openGeoPlace,
      onError: (Object error, StackTrace stackTrace) {
        AppDiagnostics.record('geo.intent', error);
      },
    );
  }

  void _openGeoPlace(Place place) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ReminderEditorPage(initialPlace: place),
        ),
      );
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void dispose() {
    unawaited(_geoIntentSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasArrivalAlert = context.select<AppController, bool>(
      (state) => state.hasArrivalAlert,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (hasArrivalAlert) const _ArrivalBanner(),
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
          ],
        ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const ReminderEditorPage()),
              ),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('New reminder'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Places',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ArrivalBanner extends StatelessWidget {
  const _ArrivalBanner();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppController>();
    final names = state.arrivedReminders.map((item) => item.title).join(', ');
    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: ListTile(
          leading: const Icon(Icons.notifications_active_rounded),
          title: const Text('You have arrived'),
          subtitle: Text(names),
          trailing: FilledButton.tonal(
            onPressed: state.dismissArrival,
            child: const Text('Dismiss'),
          ),
        ),
      ),
    );
  }
}
