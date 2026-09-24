import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/services/update_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UpdateService _updates = UpdateService();
  AppUpdate? _availableUpdate;
  bool _checkingForUpdate = false;
  bool _checkedForUpdate = false;
  String? _updateError;

  @override
  void dispose() {
    _updates.dispose();
    super.dispose();
  }

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
            ListTile(
              leading: const Icon(Icons.system_update_alt_rounded),
              title: Text(
                _availableUpdate == null
                    ? 'Check for updates'
                    : 'Update available',
              ),
              subtitle: Text(_updateSubtitle),
              trailing: _checkingForUpdate
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _availableUpdate == null
                          ? Icons.refresh_rounded
                          : Icons.download_rounded,
                    ),
              onTap: _checkingForUpdate ? null : _handleUpdateTap,
            ),
          ],
        ),
      ],
    );
  }

  String get _updateSubtitle {
    if (_checkingForUpdate) return 'Checking GitHub Releases…';
    if (_availableUpdate != null) {
      return 'Version ${_availableUpdate!.version} is ready to download.';
    }
    if (_updateError != null) return _updateError!;
    if (_checkedForUpdate) return 'You have the latest version.';
    return 'Installed version: ${AppMetadata.current.version}';
  }

  Future<void> _handleUpdateTap() async {
    final update = _availableUpdate;
    if (update != null) {
      await _openUri(context, update.downloadUri);
      return;
    }
    setState(() {
      _checkingForUpdate = true;
      _updateError = null;
    });
    try {
      final result = await _updates.check();
      if (!mounted) return;
      setState(() {
        _availableUpdate = result;
        _checkedForUpdate = true;
      });
    } on UpdateException catch (error) {
      if (!mounted) return;
      setState(() {
        _updateError = error.message;
        _checkedForUpdate = true;
      });
    } finally {
      if (mounted) setState(() => _checkingForUpdate = false);
    }
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
