import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/l10n/l10n.dart';
import 'package:loc/pages/map_picker_page.dart';
import 'package:loc/place_presentation.dart';
import 'package:loc/themes/tokens.dart';
import 'package:loc/widgets/app_components.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ReminderEditorPage extends StatefulWidget {
  const ReminderEditorPage({this.reminder, this.initialPlace, super.key});

  final Reminder? reminder;
  final Place? initialPlace;

  @override
  State<ReminderEditorPage> createState() => _ReminderEditorPageState();
}

class _ReminderEditorPageState extends State<ReminderEditorPage> {
  static const _hideExternalMapGuidanceKey = 'external_map_guidance_hidden';
  static const _radiusValues = [
    20,
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    1500,
    2000,
    3000,
    4000,
    5000,
    6000,
    7000,
    8000,
    9000,
    10000,
    15000,
    20000,
    25000,
    30000,
    35000,
    40000,
    45000,
    50000,
  ];

  final _formKey = GlobalKey<FormState>();
  late final StreamSubscription<Place> _geoIntentSubscription;
  late final TextEditingController _title;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late double _radius;
  late ReminderAlertStyle _alertStyle;
  Place? _selectedPlace;
  String? _destinationError;
  bool _showCoordinates = false;
  bool _titleWasAutoFilled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final place = widget.initialPlace ?? widget.reminder?.place;
    _selectedPlace = place;
    final initialTitle =
        widget.reminder?.title ?? (place == null ? '' : place.displayTitle);
    _title = TextEditingController(text: initialTitle);
    _titleWasAutoFilled = widget.reminder == null && place != null;
    _latitude = TextEditingController(
      text: place?.position.latitude.toString(),
    );
    _longitude = TextEditingController(
      text: place?.position.longitude.toString(),
    );
    _radius = (place?.radius ?? Place.defaultRadius).toDouble();
    _alertStyle = widget.reminder?.alertStyle ?? ReminderAlertStyle.brief;
    _geoIntentSubscription = GeoUriService.places.listen(
      _usePlace,
      onError: (Object _, StackTrace _) {},
    );
  }

  @override
  void dispose() {
    unawaited(_geoIntentSubscription.cancel());
    _title.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radiusIndex = _radiusIndex;
    final compactAlertSegments =
        MediaQuery.textScalerOf(context).scale(16) >= 24;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminder == null
              ? context.l10n.newReminderTitle
              : context.l10n.editReminderTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.compact,
            AppSpacing.page,
            AppSpacing.group,
          ),
          children: [
            _EditorSection(
              icon: Icons.location_on_outlined,
              title: context.l10n.destinationLabel,
              child: _buildDestination(context),
            ),
            const SizedBox(height: 16),
            _EditorSection(
              icon: Icons.notifications_none_rounded,
              title: context.l10n.alertLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.l10n.notifyWithinLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _formatDistance(context, _radius.round()),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colors.onTertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: radiusIndex.toDouble(),
                    max: (_radiusValues.length - 1).toDouble(),
                    divisions: _radiusValues.length - 1,
                    label: _formatDistance(context, _radiusValues[radiusIndex]),
                    semanticFormatterCallback: (value) =>
                        _formatDistanceSemantic(
                          context,
                          _radiusValues[value.round()],
                        ),
                    onChanged: (value) => setState(
                      () => _radius = _radiusValues[value.round()].toDouble(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDistance(context, _radiusValues.first),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDistance(context, _radiusValues.last),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.group),
                  SegmentedButton<ReminderAlertStyle>(
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      ButtonSegment(
                        value: ReminderAlertStyle.brief,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.volume_up_outlined),
                        label: Text(context.l10n.alertStyleSound),
                      ),
                      ButtonSegment(
                        value: ReminderAlertStyle.vibration,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.vibration_rounded),
                        label: Text(context.l10n.alertStyleVibrate),
                      ),
                      ButtonSegment(
                        value: ReminderAlertStyle.alarm,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.alarm_rounded),
                        label: Text(context.l10n.alertStyleAlarm),
                      ),
                    ],
                    selected: {_alertStyle},
                    selectedIcon: const Icon(Icons.check_rounded, size: 18),
                    showSelectedIcon: !compactAlertSegments,
                    onSelectionChanged: (value) =>
                        setState(() => _alertStyle = value.single),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    switch (_alertStyle) {
                      ReminderAlertStyle.brief =>
                        context.l10n.alertStyleSoundDescription,
                      ReminderAlertStyle.vibration =>
                        context.l10n.alertStyleVibrateDescription,
                      ReminderAlertStyle.alarm =>
                        context.l10n.alertStyleAlarmDescription,
                    },
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: colors.surface,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            10,
            AppSpacing.page,
            AppSpacing.compact,
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: GeoUriService.isResolving,
            builder: (context, isResolving, _) {
              final busy = _saving || isResolving;
              return FilledButton.icon(
                onPressed: busy ? null : _save,
                icon: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.notifications_none_rounded),
                label: Text(
                  isResolving
                      ? context.l10n.retrievingLocationAddress
                      : _saving
                      ? context.l10n.savingLabel
                      : widget.reminder == null
                      ? context.l10n.createReminderAction
                      : context.l10n.saveChangesAction,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final place = _selectedPlace;
    final stackActions = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final secondaryStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(AppControlHeights.control),
      side: BorderSide(color: colors.outlineVariant),
      foregroundColor: colors.onSurfaceVariant,
    );
    final otherMapButton = OutlinedButton.icon(
      style: secondaryStyle,
      onPressed: _pickWithExternalMap,
      icon: const Icon(Icons.open_in_new_rounded, size: 20),
      label: Text(context.l10n.otherMapAction),
    );
    final coordinatesButton = OutlinedButton.icon(
      style: secondaryStyle,
      onPressed: () => setState(() => _showCoordinates = !_showCoordinates),
      icon: Icon(
        _showCoordinates
            ? Icons.keyboard_arrow_up_rounded
            : Icons.location_on_outlined,
        size: 20,
      ),
      label: Text(
        _showCoordinates
            ? context.l10n.hideCoordinatesAction
            : context.l10n.coordinatesShortLabel,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() => _titleWasAutoFilled = false),
          decoration: InputDecoration(
            labelText: context.l10n.reminderNameLabel,
            hintText: context.l10n.reminderNameHint,
            suffixIcon: _title.text.isEmpty
                ? null
                : IconButton(
                    tooltip: context.l10n.clearReminderNameTooltip,
                    onPressed: () => setState(() {
                      _title.clear();
                      _titleWasAutoFilled = false;
                    }),
                    icon: const Icon(Icons.cancel_rounded),
                  ),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? context.l10n.reminderNameRequiredError
              : null,
        ),
        const SizedBox(height: 10),
        if (place != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.compact),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: AppRadius.chipRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    place.displaySubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: place.displaySubtitleDirection,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: _pickOnMap,
                  child: Text(context.l10n.changeAction),
                ),
              ],
            ),
          )
        else
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppControlHeights.control),
              backgroundColor: colors.secondary,
              foregroundColor: colors.onSecondary,
            ),
            onPressed: _pickOnMap,
            icon: const Icon(Icons.map_outlined),
            label: Text(context.l10n.chooseOnMapAction),
          ),
        const SizedBox(height: 8),
        if (stackActions)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              otherMapButton,
              const SizedBox(height: 8),
              coordinatesButton,
            ],
          )
        else
          Row(
            children: [
              Expanded(child: otherMapButton),
              const SizedBox(width: 8),
              Expanded(child: coordinatesButton),
            ],
          ),
        if (_showCoordinates) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _coordinateField(
                  _latitude,
                  context.l10n.latitudeLabel,
                  -90,
                  90,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _coordinateField(
                  _longitude,
                  context.l10n.longitudeLabel,
                  -180,
                  180,
                ),
              ),
            ],
          ),
        ],
        if (_destinationError != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8, start: 12),
            child: Text(
              _destinationError!,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  TextFormField _coordinateField(
    TextEditingController controller,
    String label,
    double minimum,
    double maximum,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {
        _selectedPlace = null;
        _destinationError = null;
      }),
      validator: (value) {
        final number = double.tryParse(value?.trim() ?? '');
        if (number == null || number < minimum || number > maximum) {
          return context.l10n.coordinateRangeError(
            minimum.toString(),
            maximum.toString(),
          );
        }
        return null;
      },
    );
  }

  int get _radiusIndex {
    var closestIndex = 0;
    var closestDistance = (_radiusValues.first - _radius).abs();
    for (var index = 1; index < _radiusValues.length; index++) {
      final distance = (_radiusValues[index] - _radius).abs();
      if (distance < closestDistance) {
        closestIndex = index;
        closestDistance = distance;
      }
    }
    return closestIndex;
  }

  String _formatDistance(BuildContext context, int meters) {
    if (meters < 1000) return context.l10n.distanceMetersShort(meters);
    final kilometers = meters / 1000;
    final value = kilometers == kilometers.roundToDouble()
        ? kilometers.round().toString()
        : kilometers.toString();
    return context.l10n.distanceKilometersShort(value);
  }

  String _formatDistanceSemantic(BuildContext context, int meters) {
    if (meters < 1000) return context.l10n.distanceMetersSemantic(meters);
    final kilometers = meters / 1000;
    final value = kilometers == kilometers.roundToDouble()
        ? kilometers.round().toString()
        : kilometers.toString();
    return context.l10n.distanceKilometersSemantic(num.parse(value));
  }

  Future<void> _pickOnMap() async {
    final place = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialPlace: _selectedPlace),
      ),
    );
    if (place == null) return;
    if (!mounted) return;
    _usePlace(place);
  }

  Future<void> _pickWithExternalMap() async {
    SharedPreferences? preferences;
    var showGuidance = true;
    try {
      preferences = await SharedPreferences.getInstance();
      showGuidance =
          !(preferences.getBool(_hideExternalMapGuidanceKey) ?? false);
    } on Object {
      // Preference storage should not prevent opening another map app.
    }
    if (!mounted) return;

    var hideGuidance = false;
    if (showGuidance) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = Theme.of(context).colorScheme;
            return AlertDialog(
              scrollable: true,
              title: Text(context.l10n.chooseInAnotherMapTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NumberedStep(
                    number: 1,
                    label: context.l10n.externalMapStepChooseDestination,
                  ),
                  const SizedBox(height: 10),
                  NumberedStep(
                    number: 2,
                    label: context.l10n.externalMapStepTapShare,
                  ),
                  const SizedBox(height: 10),
                  NumberedStep(
                    number: 3,
                    label: context.l10n.externalMapStepSelectLoc,
                    trailing: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 24,
                      height: 24,
                      semanticLabel: context.l10n.appIconSemanticLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    checked: hideGuidance,
                    label: context.l10n.dontShowAgain,
                    onTap: () =>
                        setDialogState(() => hideGuidance = !hideGuidance),
                    child: ExcludeSemantics(
                      child: InkWell(
                        borderRadius: AppRadius.chipRadius,
                        onTap: () =>
                            setDialogState(() => hideGuidance = !hideGuidance),
                        child: SizedBox(
                          width: double.infinity,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: AppControlHeights.control,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  hideGuidance
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded,
                                  size: 20,
                                  color: hideGuidance
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    context.l10n.dontShowAgain,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(context.l10n.openMapAction),
                ),
              ],
            );
          },
        ),
      );
      if (shouldOpen != true || !mounted) return;

      if (hideGuidance && preferences != null) {
        try {
          await preferences.setBool(_hideExternalMapGuidanceKey, true);
        } on Object {
          // The map can still open if saving the opt-out fails.
        }
        if (!mounted) return;
      }
    }

    final center =
        context.read<AppController>().currentPosition ??
        _selectedPlace?.position;
    final uri = center == null
        ? Uri.parse('geo:0,0')
        : Uri.parse('geo:${center.latitude},${center.longitude}?z=14');
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      // The fallback message below also covers platform launch failures.
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noCompatibleMapAppError)),
      );
    }
  }

  void _usePlace(Place place) {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    setState(() {
      if (widget.reminder == null &&
          (_title.text.trim().isEmpty || _titleWasAutoFilled)) {
        _title.text = place.displayTitle;
        _titleWasAutoFilled = true;
      }
      _selectedPlace = place;
      _destinationError = null;
      _latitude.text = place.position.latitude.toStringAsFixed(6);
      _longitude.text = place.position.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _save() async {
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    if (latitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude == null ||
        longitude < -180 ||
        longitude > 180) {
      setState(() {
        _destinationError = context.l10n.destinationRequiredError;
        _showCoordinates = true;
      });
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppController>();
    setState(() => _saving = true);
    final point = Point(latitude: latitude, longitude: longitude);
    final place = Place(
      position: point,
      radius: _radius.round(),
      displayName: _selectedPlace?.position == point
          ? _selectedPlace?.displayName
          : null,
    );
    final existing = widget.reminder;
    final reminder = Reminder(
      id: existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      place: place,
      isTracking: existing?.isTracking ?? true,
      isArrived: false,
      isAlarm: _alertStyle == ReminderAlertStyle.alarm,
      isVibration: _alertStyle == ReminderAlertStyle.vibration,
      isPinned: existing?.isPinned ?? false,
    );
    try {
      await state.saveReminder(reminder);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            icon: const Icon(Icons.error_outline_rounded),
            title: Text(context.l10n.reminderNotSavedTitle),
            content: Text(context.l10n.reminderNotSavedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.keepEditingAction),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AppSectionCard(icon: icon, title: title, child: child);
}
