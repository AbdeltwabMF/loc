import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/power_service.dart';
import 'package:loc/themes/tokens.dart';
import 'package:provider/provider.dart';

class PermissionSetupPage extends StatefulWidget {
  const PermissionSetupPage({
    required this.initialSetup,
    this.powerService,
    super.key,
  });

  final bool initialSetup;
  final PowerService? powerService;

  @override
  State<PermissionSetupPage> createState() => _PermissionSetupPageState();
}

class _PermissionSetupPageState extends State<PermissionSetupPage>
    with WidgetsBindingObserver {
  late final PowerService _powerService;
  LocationAccessStatus? _locationStatus;
  bool? _batteryExempt;
  bool _busy = false;
  bool _showBackgroundSettingsHelp = false;

  @override
  void initState() {
    super.initState();
    _powerService = widget.powerService ?? PowerService();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final controller = context.read<AppController>();
    await controller.refreshTrackingState();
    if (_showBackgroundSettingsHelp &&
        controller.backgroundLocationAllowed &&
        !controller.backgroundTrackingEnabled) {
      final enabled = await controller.setBackgroundTrackingEnabled(true);
      if (enabled) _showBackgroundSettingsHelp = false;
    }
    final locationStatus = await controller.locationAccessStatus();
    final batteryExempt = await _powerService.isBatteryExempt();
    if (!mounted) return;
    setState(() {
      _locationStatus = locationStatus;
      _batteryExempt = batteryExempt;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) await _refresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestLocation() => _run(() async {
    await context.read<AppController>().requestForegroundLocation();
  });

  Future<void> _requestNotifications() => _run(() async {
    await context.read<AppController>().setAlarmEnabled(true);
  });

  Future<void> _requestBackgroundLocation() => _run(() async {
    final controller = context.read<AppController>();
    if (await controller.setBackgroundTrackingEnabled(true)) {
      _showBackgroundSettingsHelp = false;
      return;
    }
    if (await controller.locationAccessStatus() == LocationAccessStatus.ready) {
      _showBackgroundSettingsHelp = true;
    }
  });

  Future<void> _openBackgroundSettings() => _run(() async {
    await context.read<AppController>().openAppSettings();
  });

  Future<void> _requestBatteryExemption() => _run(() async {
    await _powerService.requestBatteryExemption();
  });

  Future<void> _continue() async {
    if (_locationStatus != LocationAccessStatus.ready) return;
    final controller = context.read<AppController>();
    if (widget.initialSetup) {
      await controller.markTrackingSetupSeen();
    } else {
      await controller.completePermissionRecovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final colors = Theme.of(context).colorScheme;
    final locationReady = _locationStatus == LocationAccessStatus.ready;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.group,
                AppSpacing.page,
                AppSpacing.page,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/app_icon.png',
                      width: 52,
                      height: 52,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Loc',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.group),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.initialSetup
                          ? 'Set up permissions'
                          : 'Location access needed',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.initialSetup
                          ? 'Loc needs the following permissions'
                          : 'Loc needs to detect when you arrive',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.group),
                Text(
                  'Required',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PermissionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  description: 'To detect when you arrive at your destination',
                  granted: locationReady,
                  actionLabel: switch (_locationStatus) {
                    LocationAccessStatus.serviceDisabled => 'Turn on',
                    LocationAccessStatus.settingsRequired => 'Open settings',
                    _ => 'Allow',
                  },
                  onPressed: _busy || locationReady ? null : _requestLocation,
                ),
                const SizedBox(height: AppSpacing.group),
                Text(
                  'Optional',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PermissionCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  description: 'To notify you when you arrive',
                  granted: controller.systemNotificationsEnabled,
                  actionLabel: 'Allow',
                  onPressed: _busy || controller.systemNotificationsEnabled
                      ? null
                      : _requestNotifications,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PermissionCard(
                  icon: Icons.screen_lock_portrait_rounded,
                  title: 'Screen-off tracking',
                  description: _showBackgroundSettingsHelp
                      ? 'In Permissions > Location, select "Allow all the time"'
                      : 'To keep reminders active when your screen is off',
                  granted: controller.backgroundTrackingEnabled,
                  actionLabel: _showBackgroundSettingsHelp
                      ? 'Open settings'
                      : 'Allow',
                  onPressed: _busy || controller.backgroundTrackingEnabled
                      ? null
                      : _showBackgroundSettingsHelp
                      ? _openBackgroundSettings
                      : _requestBackgroundLocation,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PermissionCard(
                  icon: Icons.battery_saver_outlined,
                  title: 'Battery access',
                  description: 'To keep active reminders running reliably',
                  granted: _batteryExempt == true,
                  actionLabel: 'Allow',
                  onPressed: _busy || _batteryExempt != false
                      ? null
                      : _requestBatteryExemption,
                ),
                const SizedBox(height: AppSpacing.group),
                FilledButton(
                  onPressed: locationReady && !_busy ? _continue : null,
                  child: Text(
                    widget.initialSetup ? 'Continue' : 'Resume reminders',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'You can change optional permissions later in Settings',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            granted
                ? Icon(Icons.check_circle_rounded, color: colors.primary)
                : TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
