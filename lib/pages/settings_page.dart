import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/power_service.dart';
import 'package:loc/themes/tokens.dart';
import 'package:loc/widgets/app_components.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  final PowerService _power = PowerService();
  bool? _batteryExempt;
  bool? _locationEnabled;
  bool _requestingExemption = false;
  bool _enablingBackgroundTracking = false;
  bool _waitingForLocationService = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshBatteryStatus();
    _refreshLocationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshBatteryStatus();
      _refreshTrackingAccess();
    }
  }

  Future<void> _refreshTrackingAccess() async {
    final controller = context.read<AppController>();
    await controller.refreshAttention();
    await _refreshLocationStatus();
    if (_waitingForLocationService && mounted) {
      setState(() => _waitingForLocationService = false);
      if (_locationEnabled == true) {
        await _setBackgroundTracking(true);
      }
      return;
    }
    if (!_enablingBackgroundTracking || !mounted) return;
    final enabled = await controller.setBackgroundTrackingEnabled(true);
    if (!mounted) return;
    setState(() => _enablingBackgroundTracking = !enabled);
  }

  Future<void> _refreshBatteryStatus() async {
    final exempt = await _power.isBatteryExempt();
    if (!mounted) return;
    setState(() => _batteryExempt = exempt);
  }

  Future<void> _refreshLocationStatus() async {
    final status = await context.read<AppController>().locationAccessStatus();
    if (!mounted) return;
    setState(
      () => _locationEnabled = status != LocationAccessStatus.serviceDisabled,
    );
  }

  Future<void> _requestExemption() async {
    setState(() => _requestingExemption = true);
    await _power.requestBatteryExemption();

    if (!mounted) return;

    setState(() => _requestingExemption = false);
    await _refreshBatteryStatus();
  }

  Future<void> _setNotifications(bool value) async {
    await context.read<AppController>().setAlarmEnabled(value);
  }

  Future<void> _setBackgroundTracking(bool value) async {
    final controller = context.read<AppController>();
    if (!value) {
      setState(() {
        _enablingBackgroundTracking = false;
        _waitingForLocationService = false;
      });
      await controller.setBackgroundTrackingEnabled(false);
      return;
    }
    final locationStatus = await controller.locationAccessStatus();
    if (!mounted) return;
    setState(
      () => _locationEnabled =
          locationStatus != LocationAccessStatus.serviceDisabled,
    );
    if (locationStatus == LocationAccessStatus.serviceDisabled) {
      setState(() => _waitingForLocationService = true);
      await controller.openLocationSettings();
      return;
    }
    if (await controller.setBackgroundTrackingEnabled(true) || !mounted) return;
    if (await controller.locationAccessStatus() != LocationAccessStatus.ready ||
        !mounted) {
      return;
    }
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Allow screen-off tracking'),
        content: const Text(
          'Open Permissions > Location and choose "Allow all the time".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (openSettings == true && mounted) {
      setState(() {
        _enablingBackgroundTracking = true;
        _waitingForLocationService = false;
      });
      await controller.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final compactAppearance = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final settings = context
        .select<
          AppController,
          ({
            bool notifications,
            bool notificationsAllowed,
            bool background,
            ThemeMode theme,
          })
        >(
          (state) => (
            notifications: state.alarmEnabled,
            notificationsAllowed: state.notificationsAllowed,
            background: state.backgroundTrackingEnabled,
            theme: state.themeMode,
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.compact,
          AppSpacing.page,
          AppSpacing.group,
        ),
        children: [
          Text(
            'Tracking access',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(
            children: [
              _SettingsSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Arrival notifications',
                subtitle: settings.notificationsAllowed
                    ? 'Notify me when I arrive.'
                    : 'Tap to allow notifications.',
                value: settings.notifications && settings.notificationsAllowed,
                onChanged: _setNotifications,
              ),
              _SettingsSwitchTile(
                icon: Icons.screen_lock_portrait_rounded,
                title: 'Screen-off tracking',
                subtitle: _locationEnabled == null
                    ? 'Checking Location status…'
                    : _locationEnabled!
                    ? 'Continue tracking when the screen is off.'
                    : 'Requires Location to be on.',
                value: settings.background,
                onChanged: _setBackgroundTracking,
              ),
            ],
          ),
          if (settings.background && _batteryExempt == false) ...[
            const SizedBox(height: AppSpacing.compact),
            AppWarningCard(
              icon: Icons.battery_alert_rounded,
              title: 'Battery optimization is on',
              description:
                  'Turn off battery restrictions for reliable screen-off tracking.',
              busy: _requestingExemption,
              onTap: _requestExemption,
            ),
          ],
          const SizedBox(height: 16),
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: const Text('System'),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.brightness_auto_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: const Text('Light'),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: const Text('Dark'),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {settings.theme},
            onSelectionChanged: (value) =>
                context.read<AppController>().setThemeMode(value.single),
          ),
        ],
      ),
    );
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

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: CompactSwitch(value: value, onChanged: onChanged),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    onTap: () => onChanged(!value),
  );
}
