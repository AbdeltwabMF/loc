import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/power_service.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Allow screen-off tracking'),
        content: const Text(
          'Open Permissions > Location and choose "Allow all the time".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Text('Tracking access', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _SettingsGroup(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Arrival notifications'),
              subtitle: Text(
                settings.notificationsAllowed
                    ? 'Notify me when I arrive.'
                    : 'Tap to allow notifications.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              value: settings.notifications && settings.notificationsAllowed,
              onChanged: _setNotifications,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.screen_lock_portrait_rounded),
              title: const Text('Screen-off tracking'),
              subtitle: Text(
                _locationEnabled == null
                    ? 'Checking Location status…'
                    : _locationEnabled!
                    ? 'Continue tracking when the screen is off.'
                    : 'Requires Location to be on.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              value: settings.background,
              onChanged: _setBackgroundTracking,
            ),
          ],
        ),
        if (settings.background && _batteryExempt == false) ...[
          const SizedBox(height: 12),
          _BatteryOptimizationCard(
            busy: _requestingExemption,
            onTap: _requestExemption,
          ),
        ],
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

class _BatteryOptimizationCard extends StatelessWidget {
  const _BatteryOptimizationCard({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.brightness == Brightness.light
        ? Gruvbox.light
        : Gruvbox.dark;

    final background = palette.orangeHard;
    final foreground = palette.bg;

    return ClipPath(
      clipper: const _SmoothWavyCardClipper(),
      child: Material(
        color: background,
        child: InkWell(
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(Icons.battery_alert_rounded, color: foreground),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery optimization is on',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Turn off battery restrictions for reliable screen-off tracking.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (busy)
                  SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothWavyCardClipper extends CustomClipper<Path> {
  const _SmoothWavyCardClipper();

  static const double _radius = 16;
  static const double _waveDepth = 4;
  static const double _waveLength = 24;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(_radius, 0);

    _waveHorizontal(
      path,
      from: _radius,
      to: size.width - _radius,
      y: 0,
      depth: _waveDepth,
    );

    path.quadraticBezierTo(size.width, 0, size.width, _radius);

    _waveVertical(
      path,
      from: _radius,
      to: size.height - _radius,
      x: size.width,
      depth: -_waveDepth,
    );

    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - _radius,
      size.height,
    );

    _waveHorizontal(
      path,
      from: size.width - _radius,
      to: _radius,
      y: size.height,
      depth: -_waveDepth,
    );

    path.quadraticBezierTo(0, size.height, 0, size.height - _radius);

    _waveVertical(
      path,
      from: size.height - _radius,
      to: _radius,
      x: 0,
      depth: _waveDepth,
    );

    path.quadraticBezierTo(0, 0, _radius, 0);

    return path..close();
  }

  void _waveHorizontal(
    Path path, {
    required double from,
    required double to,
    required double y,
    required double depth,
  }) {
    final distance = (to - from).abs();
    final direction = to >= from ? 1.0 : -1.0;

    final waveCount = (distance / _waveLength).round().clamp(1, 1000);
    final waveWidth = distance / waveCount;

    for (var i = 0; i < waveCount; i++) {
      final start = from + direction * waveWidth * i;
      final end = start + direction * waveWidth;

      path
        ..cubicTo(
          start + direction * waveWidth * 0.25,
          y,
          start + direction * waveWidth * 0.25,
          y + depth,
          start + direction * waveWidth * 0.5,
          y + depth,
        )
        ..cubicTo(
          start + direction * waveWidth * 0.75,
          y + depth,
          start + direction * waveWidth * 0.75,
          y,
          end,
          y,
        );
    }
  }

  void _waveVertical(
    Path path, {
    required double from,
    required double to,
    required double x,
    required double depth,
  }) {
    final distance = (to - from).abs();
    final direction = to >= from ? 1.0 : -1.0;

    final waveCount = (distance / _waveLength).round().clamp(1, 1000);
    final waveHeight = distance / waveCount;

    for (var i = 0; i < waveCount; i++) {
      final start = from + direction * waveHeight * i;
      final end = start + direction * waveHeight;

      path
        ..cubicTo(
          x,
          start + direction * waveHeight * 0.25,
          x + depth,
          start + direction * waveHeight * 0.25,
          x + depth,
          start + direction * waveHeight * 0.5,
        )
        ..cubicTo(
          x + depth,
          start + direction * waveHeight * 0.75,
          x,
          start + direction * waveHeight * 0.75,
          x,
          end,
        );
    }
  }

  @override
  bool shouldReclip(covariant _SmoothWavyCardClipper oldClipper) => false;
}
