import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/pages/reminders_page.dart';
import 'package:loc/pages/settings_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _index = 0;
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
      unawaited(context.read<AppController>().refreshAttention());
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
    final alerts = context
        .select<AppController, ({bool arrival, bool attention})>(
          (state) => (
            arrival: state.hasArrivalAlert,
            attention: state.locationError != null && state.activeCount > 0,
          ),
        );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (alerts.arrival) const _StatusBanner(_BannerType.arrival),
            if (alerts.attention) const _StatusBanner(_BannerType.attention),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  RemindersPage(isActive: _index == 0),
                  const SettingsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const ReminderEditorPage()),
              ),
              tooltip: 'New reminder',
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_location_alt_rounded),
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
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

enum _BannerType { arrival, attention }

class _StatusBanner extends StatelessWidget {
  const _StatusBanner(this.type);

  final _BannerType type;

  @override
  Widget build(BuildContext context) {
    final alert = context
        .select<
          AppController,
          ({
            String arrivals,
            String? error,
            bool canResolve,
            String actionLabel,
          })
        >(
          (state) => (
            arrivals: state.arrivedReminders
                .map((item) => item.title)
                .join(', '),
            error: state.locationError,
            canResolve: state.attentionAction != null,
            actionLabel: state.attentionActionLabel,
          ),
        );
    final isArrival = type == _BannerType.arrival;
    final colors = Theme.of(context).colorScheme;
    final foreground = isArrival ? colors.onSecondary : colors.onError;
    return Material(
      color: isArrival ? colors.secondary : colors.error,
      child: ListTile(
        iconColor: foreground,
        textColor: foreground,
        leading: Icon(
          isArrival
              ? Icons.notifications_active_rounded
              : Icons.warning_amber_rounded,
        ),
        title: Text(isArrival ? 'You have arrived' : 'Attention needed'),
        subtitle: Text(isArrival ? alert.arrivals : alert.error ?? ''),
        trailing: isArrival
            ? FilledButton.tonal(
                onPressed: context.read<AppController>().dismissArrival,
                child: const Text('Dismiss'),
              )
            : FilledButton.tonal(
                onPressed: alert.canResolve
                    ? context.read<AppController>().resolveAttention
                    : null,
                child: Text(alert.actionLabel),
              ),
      ),
    );
  }
}
