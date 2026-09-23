import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:loc/data/services/geocoding_service.dart';
import 'package:loc/pages/map_picker_page.dart';
import 'package:provider/provider.dart';
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
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late double _radius;
  late bool _isAlarm;
  Place? _selectedPlace;
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
    _isAlarm = widget.reminder?.isAlarm ?? false;
  }

  @override
  void dispose() {
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
              tooltip: 'Save destination',
              onPressed: () async {
                final added = await context.read<AppController>().addFavorite(
                  widget.reminder!.place,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? 'Destination saved.'
                            : 'Destination already saved.',
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            Text(
              'Where should we wake you?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a pin, then set how close you want to be before the alarm starts.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Reminder name',
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
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Exit on the east side',
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              label: 'Destination',
              action: TextButton.icon(
                onPressed: _pickOnMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open map'),
              ),
            ),
            if (_selectedPlace?.displayName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_selectedPlace!.displayName!, maxLines: 2),
              ),
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
            const SizedBox(height: 24),
            _SectionTitle(
              label: 'Arrival radius',
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
              _radius < 500
                  ? 'Precise, best for walking or slow traffic.'
                  : 'Wider radius, better for fast roads or weak GPS reception.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle(label: 'Alert style'),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.notifications_outlined),
                  label: Text('Brief'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.alarm_rounded),
                  label: Text('Alarm'),
                ),
              ],
              selected: {_isAlarm},
              onSelectionChanged: (value) =>
                  setState(() => _isAlarm = value.single),
            ),
            const SizedBox(height: 10),
            Text(
              _isAlarm
                  ? 'Repeats until dismissed to help wake you.'
                  : 'Plays the notification sound once.',
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
    setState(() {
      _selectedPlace = place;
      _latitude.text = place.position.latitude.toStringAsFixed(6);
      _longitude.text = place.position.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = context.read<AppController>();
    final point = Point(
      latitude: double.parse(_latitude.text.trim()),
      longitude: double.parse(_longitude.text.trim()),
    );
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
      isAlarm: _isAlarm,
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
              'happening, copy Support diagnostics from Settings when '
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
  const _SectionTitle({required this.label, this.action, this.value});

  final String label;
  final Widget? action;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (value != null)
        Text(value!, style: Theme.of(context).textTheme.titleMedium),
      ?action,
    ],
  );
}
