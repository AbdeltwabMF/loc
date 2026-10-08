import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/pages/reminders_page.dart';
import 'package:loc/pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final StreamSubscription<Place> _geoIntentSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _geoIntentSubscription = GeoUriService.places.listen(
      _openGeoPlace,
      onError: (Object _, StackTrace _) {},
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<AppController>().refreshTrackingState());
    }
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
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_geoIntentSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RemindersPage(
          onSettingsPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
          onSourceCodePressed: () => unawaited(
            _openExternal('https://github.com/AbdeltwabMF/loc'),
          ),
          onPrivacyPolicyPressed: () => unawaited(
            _openExternal('https://loc.abdeltwab.xyz/privacy.html'),
          ),
          onAboutPressed: _showAbout,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const ReminderEditorPage()),
        ),
        tooltip: 'New reminder',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_location_alt_rounded),
      ),
    );
  }

  Future<void> _openExternal(String value) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(value),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      // The message below also covers platform launch failures.
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that link.')),
      );
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Loc',
      applicationVersion: AppMetadata.current.displayVersion,
      applicationIcon: Image.asset(
        'assets/icons/app_icon.png',
        width: 48,
        height: 48,
        semanticLabel: 'Loc icon',
      ),
      applicationLegalese: 'Licensed under GPL-3.0',
    );
  }
}
