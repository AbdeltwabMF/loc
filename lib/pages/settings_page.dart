import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/pages/diagnostics_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        _SettingsGroup(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.alarm_rounded),
              title: const Text('Arrival alerts'),
              subtitle: const Text(
                'Allow reminders to alert you when you\'re nearby.',
              ),
              value: state.alarmEnabled,
              onChanged: state.setAlarmEnabled,
            ),
            ListTile(
              leading: const Icon(Icons.location_searching_rounded),
              title: const Text('Location access'),
              subtitle: Text(
                state.locationError ?? 'Required for active reminders.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: Geolocator.openAppSettings,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto_rounded),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (value) => state.setThemeMode(value.single),
        ),
        const SizedBox(height: 18),
        _SettingsGroup(
          children: [
            ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
              title: const Text('Diagnostics'),
              subtitle: const Text('Check location and internet access.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const DiagnosticsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Source code'),
              subtitle: const Text('GPL-3.0 licensed'),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => _open(context, 'https://github.com/AbdeltwabMF/loc'),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Map data'),
              subtitle: const Text(
                '© OpenStreetMap contributors · Search powered by Nominatim',
              ),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () =>
                  _open(context, 'https://www.openstreetmap.org/copyright'),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report a map issue'),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () =>
                  _open(context, 'https://www.openstreetmap.org/fixthemap'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Loc ${AppMetadata.current.version} · No account. No analytics. '
          'Location and search data are '
          'processed on your device and by OpenStreetMap services.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, String value) async {
    final opened = await launchUrl(
      Uri.parse(value),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that link.')),
      );
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1)
            const Divider(height: 1, indent: 56),
        ],
      ],
    ),
  );
}
