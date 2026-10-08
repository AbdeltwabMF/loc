import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/power_service.dart';
import 'package:loc/l10n/l10n.dart';
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
    await controller.refreshTrackingState();
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
    if (await controller.setBackgroundTrackingEnabled(true)) {
      return;
    }
    if (!mounted) return;
    if (await controller.locationAccessStatus() != LocationAccessStatus.ready ||
        !mounted) {
      return;
    }
    setState(() {
      _enablingBackgroundTracking = true;
      _waitingForLocationService = false;
    });
  }

  Future<void> _openBackgroundLocationSettings() async {
    await context.read<AppController>().openAppSettings();
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
            bool useSystemFont,
            Locale? locale,
          })
        >(
          (state) => (
            notifications: state.alarmEnabled,
            notificationsAllowed: state.notificationsAllowed,
            background: state.backgroundTrackingEnabled,
            theme: state.themeMode,
            useSystemFont: state.useSystemFont,
            locale: state.locale,
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.compact,
          AppSpacing.page,
          AppSpacing.group,
        ),
        children: [
          Text(
            context.l10n.trackingAccessHeading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(
            children: [
              _SettingsSwitchTile(
                icon: Icons.notifications_outlined,
                title: context.l10n.arrivalNotifications,
                subtitle: settings.notificationsAllowed
                    ? context.l10n.arrivalNotificationsEnabledDescription
                    : context.l10n.allowNotificationsPrompt,
                value: settings.notifications && settings.notificationsAllowed,
                onChanged: _setNotifications,
              ),
              _SettingsSwitchTile(
                icon: Icons.screen_lock_portrait_rounded,
                title: context.l10n.screenOffTracking,
                subtitle: _locationEnabled == null
                    ? context.l10n.checkingLocationStatus
                    : _locationEnabled!
                    ? context.l10n.screenOffTrackingDescription
                    : context.l10n.locationServiceRequired,
                value: settings.background,
                onChanged: _setBackgroundTracking,
              ),
            ],
          ),
          if (_enablingBackgroundTracking && !settings.background) ...[
            const SizedBox(height: AppSpacing.compact),
            AppWarningCard(
              icon: Icons.location_on_outlined,
              title: context.l10n.allowLocationAllTheTimeTitle,
              description: context.l10n.allowLocationAllTheTimeInstructions,
              onTap: _openBackgroundLocationSettings,
            ),
          ],
          if (settings.background && _batteryExempt == false) ...[
            const SizedBox(height: AppSpacing.compact),
            AppWarningCard(
              icon: Icons.battery_alert_rounded,
              title: context.l10n.batteryOptimizationOnTitle,
              description: context.l10n.disableBatteryRestrictionsDescription,
              busy: _requestingExemption,
              onTap: _requestExemption,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            context.l10n.appearanceHeading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(context.l10n.themeSystem),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.brightness_auto_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(context.l10n.themeLight),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(context.l10n.themeDark),
                icon: compactAppearance
                    ? null
                    : const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {settings.theme},
            onSelectionChanged: (value) =>
                context.read<AppController>().setThemeMode(value.single),
          ),
          const SizedBox(height: AppSpacing.compact),
          _SettingsGroup(
            children: [
              _LanguageMenu(locale: settings.locale),
              _SettingsSwitchTile(
                icon: Icons.font_download_outlined,
                title: context.l10n.useSystemFont,
                subtitle: settings.useSystemFont
                    ? context.l10n.systemFontDescription
                    : _bundledFontName(context),
                value: settings.useSystemFont,
                onChanged: context.read<AppController>().setUseSystemFont,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _bundledFontName(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar'
    ? context.l10n.fontBalooBhaijaan2
    : context.l10n.fontGoogleSans;

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu({required this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final selected = locale?.languageCode;
    return PopupMenuButton<String>(
      initialValue: selected ?? 'system',
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      onSelected: (value) => context.read<AppController>().setLocale(
        value == 'system' ? null : Locale(value),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'system',
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(context.l10n.languageSystem),
        ),
        PopupMenuItem(
          value: 'en',
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(context.l10n.languageEnglish),
        ),
        PopupMenuItem(
          value: 'ar',
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(context.l10n.languageArabic),
        ),
      ],
      child: ListTile(
        leading: const Icon(Icons.language_rounded),
        title: Text(context.l10n.language),
        subtitle: Text(switch (selected) {
          'en' => context.l10n.languageEnglish,
          'ar' => context.l10n.languageArabic,
          _ => context.l10n.languageSystem,
        }),
        trailing: const Icon(Icons.arrow_drop_down_rounded),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.card),
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
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 56),
              child: Divider(height: 1),
            ),
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
