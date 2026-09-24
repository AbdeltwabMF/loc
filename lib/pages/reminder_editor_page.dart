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
        widget.reminder?.title ?? (place == null ? '' : _placeTitle(place));
    _title = TextEditingController(text: initialTitle);
    _titleWasAutoFilled = widget.reminder == null && place != null;
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
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'New reminder' : 'Edit reminder'),
        actions: [
          if (widget.reminder != null)
            IconButton(
              tooltip: 'Save place',
              onPressed: () async {
                final added = await context.read<AppController>().addSavedPlace(
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
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Notify me when I’m within',
                                style: Theme.of(context).textTheme.titleMedium,
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
                                '${_radius.round()}m',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: colors.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _radius,
                          min: 100,
                          max: 5000,
                          divisions: 49,
                          onChanged: (value) => setState(() => _radius = value),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '100m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '5km',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _distanceHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Notification',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<ReminderAlertStyle>(
                          expandedInsets: EdgeInsets.zero,
                          segments: const [
                            ButtonSegment(
                              value: ReminderAlertStyle.brief,
                              icon: Icon(Icons.volume_up_outlined),
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
                          showSelectedIcon: false,
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
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
                    _placeSubtitle(place),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: textDirectionFor(_placeSubtitle(place)),
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
            onPressed: _pickOnMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pick on Loc map'),
          ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.open_in_new_rounded,
          label: 'Choose with another map app',
          onTap: _pickWithExternalMap,
        ),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.location_on_outlined,
          label: _showCoordinates
              ? 'Hide manual coordinates'
              : 'Enter coordinates manually',
          trailing: _showCoordinates
              ? Icons.keyboard_arrow_up_rounded
              : Icons.chevron_right_rounded,
          onTap: () => setState(() => _showCoordinates = !_showCoordinates),
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

  String get _distanceHint {
    if (_radius <= 250) return 'Best for walking or precise destinations.';
    if (_radius <= 1000) return 'Good for driving or public transport.';
    return 'Useful on fast roads or where GPS coverage is weaker.';
  }

  String _placeTitle(Place? place) {
    final name = place?.displayName?.trim();
    if (name == null || name.isEmpty) return 'Dropped pin';
    return name.split(',').first.trim();
  }

  String _placeSubtitle(Place place) {
    final name = place.displayName?.trim();
    if (name != null && name.contains(',')) {
      return name.substring(name.indexOf(',') + 1).trim();
    }
    return '${place.position.latitude.toStringAsFixed(5)}, '
        '${place.position.longitude.toStringAsFixed(5)}';
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
      if (widget.reminder == null &&
          (_title.text.trim().isEmpty || _titleWasAutoFilled)) {
        _title.text = _placeTitle(place);
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
    final current = state.currentPosition;
    final existing = widget.reminder;
    final reminder = Reminder(
      id: existing?.id ?? const Uuid().v4(),
      title: _title.text.trim(),
      notes: existing?.notes,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: colors.primary, size: 28),
                const SizedBox(width: 12),
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
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(trailing, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
