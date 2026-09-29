import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context
        .select<AppController, ({bool enabled, ThemeMode theme})>(
          (state) => (enabled: state.alarmEnabled, theme: state.themeMode),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        _SettingsGroup(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.alarm_rounded),
              title: const Text('System notifications'),
              subtitle: const Text(
                'Show an Android notification on arrival. The in-app banner '
                'always remains available.',
              ),
              value: settings.enabled,
              onChanged: context.read<AppController>().setAlarmEnabled,
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
          selected: {settings.theme},
          onSelectionChanged: (value) =>
              context.read<AppController>().setThemeMode(value.single),
        ),
        const SizedBox(height: 18),
        Text('About', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _SettingsGroup(
          children: [
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('Source code'),
              subtitle: const Text('GPL-3.0 licensed'),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => _open(context, 'https://github.com/AbdeltwabMF/loc'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              subtitle: const Text('Read the privacy policy'),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () =>
                  _open(context, 'https://loc.abdeltwab.xyz/privacy.html'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('App version'),
              subtitle: Text(AppMetadata.current.displayVersion),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, String value) async {
    await _openUri(context, Uri.parse(value));
  }

  Future<void> _openUri(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
