import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/data/services/geocoding_service.dart';
import 'package:loc/pages/map_picker_page.dart';
import 'package:loc/text_direction.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _geocoding = GeocodingService();
  late final StreamSubscription<Place> _geoIntentSubscription;
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late double _radius;
  late ReminderAlertStyle _alertStyle;
  Place? _selectedPlace;
  String? _destinationError;
  bool _showCoordinates = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final place = widget.initialPlace ?? widget.reminder?.place;
    _selectedPlace = place;
    _title = TextEditingController(text: widget.reminder?.title);
    _notes = TextEditingController(text: widget.reminder?.notes);
    _latitude = TextEditingController(
      text: place?.position.latitude.toString(),
    );
    _longitude = TextEditingController(
      text: place?.position.longitude.toString(),
    );
    _radius = (place?.radius ?? 500).toDouble();
    _alertStyle = widget.reminder?.alertStyle ?? ReminderAlertStyle.brief;
    _geoIntentSubscription = GeoUriService.places.listen(
      _usePlace,
      onError: (Object error, StackTrace stackTrace) {
        AppDiagnostics.record('geo.intent.editor', error);
      },
    );
  }

  @override
  void dispose() {
    unawaited(_geoIntentSubscription.cancel());
    _geocoding.dispose();
    _title.dispose();
    _notes.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'New reminder' : 'Edit reminder'),
        actions: [
          if (widget.reminder != null)
            IconButton(
              tooltip: 'Save place',
              onPressed: () async {
                final added = await context.read<AppController>().addFavorite(
                  widget.reminder!.place,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added ? 'Place saved.' : 'Place already saved.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
          if (widget.reminder != null)
            IconButton(
              tooltip: 'Delete reminder',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
          children: [
            Text(
              'Where are you going?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a destination and when you want to be alerted.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Central station',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a reminder name.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notes,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Exit on the east side',
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(label: 'Destination'),
            const SizedBox(height: 10),
            if (_selectedPlace != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(
                    _selectedPlace!.displayName ?? 'Dropped pin',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: textDirectionFor(
                      _selectedPlace!.displayName ?? 'Dropped pin',
                    ),
                  ),
                  subtitle: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_selectedPlace!.position.latitude.toStringAsFixed(5)}, '
                      '${_selectedPlace!.position.longitude.toStringAsFixed(5)}',
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: _pickOnMap,
                    child: const Text('Change'),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickOnMap,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Search or pick on Loc map'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickWithExternalMap,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Pick with external map app'),
                  ),
                ],
              ),
            if (_selectedPlace != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickWithExternalMap,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Choose in another map app'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
              child: Text(
                'To return, share or open the selected location with Loc.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_destinationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _destinationError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    setState(() => _showCoordinates = !_showCoordinates),
                child: Text(
                  _showCoordinates
                      ? 'Hide coordinates'
                      : 'Enter coordinates manually',
                ),
              ),
            ),
            if (_showCoordinates) ...[
              Row(
                children: [
                  Expanded(
                    child: _coordinateField(_latitude, 'Latitude', -90, 90),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _coordinateField(_longitude, 'Longitude', -180, 180),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            _SectionTitle(
              label: 'Alert distance',
              value: '${_radius.round()} m',
            ),
            Slider(
              value: _radius,
              min: 100,
              max: 5000,
              divisions: 49,
              label: '${_radius.round()} m',
              onChanged: (value) => setState(() => _radius = value),
            ),
            Text(
              'Get alerted when you\'re within this distance of your destination.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A larger radius works better on fast roads or with weak GPS.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(label: 'Alert type'),
            const SizedBox(height: 10),
            SegmentedButton<ReminderAlertStyle>(
              segments: const [
                ButtonSegment(
                  value: ReminderAlertStyle.brief,
                  icon: Icon(Icons.notifications_outlined),
                  label: Text('Sound'),
                ),
                ButtonSegment(
                  value: ReminderAlertStyle.vibration,
                  icon: Icon(Icons.vibration_rounded),
                  label: Text('Vibrate'),
                ),
                ButtonSegment(
                  value: ReminderAlertStyle.alarm,
                  icon: Icon(Icons.alarm_rounded),
                  label: Text('Alarm'),
                ),
              ],
              selected: {_alertStyle},
              onSelectionChanged: (value) =>
                  setState(() => _alertStyle = value.single),
            ),
            const SizedBox(height: 10),
            Text(
              switch (_alertStyle) {
                ReminderAlertStyle.brief => 'Plays one notification sound.',
                ReminderAlertStyle.vibration =>
                  'Vibrates without playing a sound.',
                ReminderAlertStyle.alarm => 'Repeats until dismissed.',
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_active_outlined),
          label: Text(_saving ? 'Saving…' : 'Save reminder'),
        ),
      ),
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
    } on Object catch (error) {
      AppDiagnostics.record('geo.external', error);
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
    final current = state.currentPosition;
    final existing = widget.reminder;
    final reminder = Reminder(
      id: existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      notes: _notes.text.trim(),
      place: place,
      initialDistance: current == null
          ? existing?.initialDistance ?? 0
          : Reminder(
              id: '',
              title: '',
              place: place,
              initialDistance: 0,
              isTracking: true,
              isArrived: false,
            ).remainderDistance(current),
      isTracking: existing?.isTracking ?? true,
      isArrived: false,
      isAlarm: _alertStyle == ReminderAlertStyle.alarm,
      isVibration: _alertStyle == ReminderAlertStyle.vibration,
    );
    try {
      await state.saveReminder(reminder);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        AppDiagnostics.record('reminder.save', error);
        setState(() => _saving = false);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.error_outline_rounded),
            title: const Text('Reminder was not saved'),
            content: const Text(
              'Your entries are still here. Try again. If this keeps '
              'happening, copy Diagnostics from Settings when '
              'reporting the issue.',
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this reminder?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AppController>().deleteReminder(widget.reminder!);
    if (mounted) Navigator.of(context).pop();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (value != null)
        Text(value!, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}
