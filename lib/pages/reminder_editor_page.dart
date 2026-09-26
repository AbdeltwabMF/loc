import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/data/services/geocoding_service.dart';
import 'package:loc/pages/map_picker_page.dart';
import 'package:loc/place_presentation.dart';
import 'package:provider/provider.dart';
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
  final _geocoding = GeocodingService();
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
    _geocoding.dispose();
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
        title: Text(widget.reminder == null ? 'New reminder' : 'Edit reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _EditorSection(
              icon: Icons.location_on_outlined,
              title: 'Destination',
              child: _buildDestination(context),
            ),
            const SizedBox(height: 14),
            _EditorSection(
              icon: Icons.notifications_none_rounded,
              title: 'Alert',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Notify me when I\'m within',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDistance(_radius.round()),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: colors.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: radiusIndex.toDouble(),
                    max: (_radiusValues.length - 1).toDouble(),
                    divisions: _radiusValues.length - 1,
                    label: _formatDistance(_radiusValues[radiusIndex]),
                    semanticFormatterCallback: (value) =>
                        _formatDistanceSemantic(_radiusValues[value.round()]),
                    onChanged: (value) => setState(
                      () => _radius = _radiusValues[value.round()].toDouble(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDistance(_radiusValues.first),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatDistance(_radiusValues.last),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  SegmentedButton<ReminderAlertStyle>(
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      ButtonSegment(
                        value: ReminderAlertStyle.brief,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.volume_up_outlined),
                        label: const Text('Sound'),
                      ),
                      ButtonSegment(
                        value: ReminderAlertStyle.vibration,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.vibration_rounded),
                        label: const Text('Vibrate'),
                      ),
                      ButtonSegment(
                        value: ReminderAlertStyle.alarm,
                        icon: compactAlertSegments
                            ? null
                            : const Icon(Icons.alarm_rounded),
                        label: const Text('Alarm'),
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
                        'Plays a notification sound once.',
                      ReminderAlertStyle.vibration =>
                        'Vibrates without playing a sound.',
                      ReminderAlertStyle.alarm =>
                        'Rings repeatedly until dismissed.',
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
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.notifications_none_rounded),
            label: Text(
              _saving
                  ? 'Saving…'
                  : widget.reminder == null
                  ? 'Create reminder'
                  : 'Save changes',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final place = _selectedPlace;
    final stackActions = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final otherMapButton = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: _pickWithExternalMap,
      icon: const Icon(Icons.open_in_new_rounded),
      label: const Text('Other map'),
    );
    final coordinatesButton = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      onPressed: () => setState(() => _showCoordinates = !_showCoordinates),
      icon: Icon(
        _showCoordinates
            ? Icons.keyboard_arrow_up_rounded
            : Icons.location_on_outlined,
      ),
      label: Text(_showCoordinates ? 'Hide coords' : 'Coords'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() => _titleWasAutoFilled = false),
          decoration: InputDecoration(
            labelText: 'Reminder name',
            hintText: 'Central station',
            suffixIcon: _title.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear reminder name',
                    onPressed: () => setState(() {
                      _title.clear();
                      _titleWasAutoFilled = false;
                    }),
                    icon: const Icon(Icons.cancel_rounded),
                  ),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a reminder name.'
              : null,
        ),
        const SizedBox(height: 10),
        if (place != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(16),
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
                TextButton(onPressed: _pickOnMap, child: const Text('Change')),
              ],
            ),
          )
        else
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: colors.tertiary,
              foregroundColor: colors.onTertiary,
            ),
            onPressed: _pickOnMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pick on Loc map'),
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
              Expanded(child: _coordinateField(_latitude, 'Latitude', -90, 90)),
              const SizedBox(width: 10),
              Expanded(
                child: _coordinateField(_longitude, 'Longitude', -180, 180),
              ),
            ],
          ),
        ],
        if (_destinationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
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
          return '$minimum to $maximum';
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

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    final kilometers = meters / 1000;
    final value = kilometers == kilometers.roundToDouble()
        ? kilometers.round().toString()
        : kilometers.toString();
    return '$value km';
  }

  String _formatDistanceSemantic(int meters) {
    if (meters < 1000) return '$meters meters';
    if (meters == 1000) return '1 kilometer';
    final kilometers = meters / 1000;
    final value = kilometers == kilometers.roundToDouble()
        ? kilometers.round().toString()
        : kilometers.toString();
    return '$value kilometers';
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
        const SnackBar(content: Text('No compatible map app is installed.')),
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
        _destinationError = 'Choose a destination or enter valid coordinates.';
        _showCoordinates = true;
      });
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = context.read<AppController>();
    final point = Point(latitude: latitude, longitude: longitude);
    var place = Place(
      position: point,
      radius: _radius.round(),
      displayName: _selectedPlace?.displayName,
    );
    if (_selectedPlace?.position != point ||
        _selectedPlace?.displayName == null) {
      try {
        final resolved = await _geocoding.reverse(point);
        place = resolved.copy(radius: _radius.round());
      } on Object {
        // Coordinates are sufficient when reverse geocoding is unavailable.
      }
    }
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
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.error_outline_rounded),
            title: const Text('Reminder was not saved'),
            content: const Text(
              'Your entries are still here. Check your connection and try '
              'again.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep editing'),
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: colors.primary, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
