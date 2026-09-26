import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/compass_service.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/place_presentation.dart';
import 'package:provider/provider.dart';

enum ReminderFilter { all, pinned, active, arrived, paused }

enum _ReminderAction { pin, delete }

class RemindersPage extends StatefulWidget {
  const RemindersPage({this.isActive = true, super.key});

  final bool isActive;

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage>
    with WidgetsBindingObserver {
  String _query = '';
  ReminderFilter _filter = ReminderFilter.all;
  final ValueNotifier<double?> _deviceHeading = ValueNotifier(null);
  StreamSubscription<double?>? _headingSubscription;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    if (widget.isActive && _lifecycleState == AppLifecycleState.resumed) {
      _startCompass();
    }
  }

  @override
  void didUpdateWidget(RemindersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive &&
        !oldWidget.isActive &&
        _lifecycleState == AppLifecycleState.resumed) {
      _startCompass();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCompass();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _startCompass();
    } else {
      _stopCompass();
    }
  }

  void _startCompass() {
    if (_headingSubscription != null) return;
    _headingSubscription = const CompassService().updates.listen(
      (heading) => _deviceHeading.value = heading,
      onError: (_) => _deviceHeading.value = null,
    );
  }

  void _stopCompass() {
    unawaited(_headingSubscription?.cancel());
    _headingSubscription = null;
    _deviceHeading.value = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCompass();
    _deviceHeading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppController>();
    final query = _query.trim().toLowerCase();
    final matchingReminders = state.reminders
        .where((item) {
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.place.displayLabel.toLowerCase().contains(query);
          final matchesFilter = switch (_filter) {
            ReminderFilter.pinned => item.isPinned,
            ReminderFilter.active => item.isTracking,
            ReminderFilter.arrived => item.isArrived,
            ReminderFilter.paused => !item.isTracking,
            ReminderFilter.all => true,
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
    final reminders = [
      ...matchingReminders.where((item) => item.isPinned),
      ...matchingReminders.where((item) => !item.isPinned),
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search reminders',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: ReminderFilter.values
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _filter == filter,
                        label: Text(_filterLabel(filter)),
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (reminders.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyReminders(hasAny: state.reminders.isNotEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
            sliver: SliverList.separated(
              itemCount: reminders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ReminderCard(
                reminder: reminders[index],
                currentPosition: state.currentPosition,
                deviceHeading: _deviceHeading,
              ),
            ),
          ),
      ],
    );
  }

  String _filterLabel(ReminderFilter filter) => switch (filter) {
    ReminderFilter.all => 'All',
    ReminderFilter.pinned => 'Pinned',
    ReminderFilter.active => 'Active',
    ReminderFilter.arrived => 'Triggered',
    ReminderFilter.paused => 'Paused',
  };
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.currentPosition,
    required this.deviceHeading,
  });

  final Reminder reminder;
  final Point? currentPosition;
  final ValueListenable<double?> deviceHeading;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppController>();
    final position = currentPosition;
    final distance = position == null
        ? null
        : reminder.remainderDistance(position).round();
    final bearing = position == null ? null : reminder.bearing(position);
    final colors = Theme.of(context).colorScheme;
    final markerColor = reminder.isArrived
        ? colors.onSecondary
        : colors.onTertiaryContainer;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ReminderEditorPage(reminder: reminder),
          ),
        ),
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: reminder.isArrived
                          ? colors.secondary
                          : colors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: bearing == null
                        ? Icon(
                            reminder.isArrived
                                ? Icons.flag_rounded
                                : Icons.location_on_rounded,
                            color: markerColor,
                          )
                        : _Compass(
                            bearing: bearing,
                            deviceHeading: deviceHeading,
                            color: markerColor,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          reminder.isArrived
                              ? 'Alert triggered'
                              : distance == null
                              ? '${reminder.place.radius ?? Place.defaultRadius} m alert distance'
                              : '${_distanceLabel(distance)} · '
                                    '${_bearingLabel(bearing!)} '
                                    '${bearing.round() % 360}°',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Switch(
                        value: reminder.isTracking,
                        onChanged: (value) async {
                          try {
                            await state.setReminderTracking(reminder, value);
                          } on Object catch (error) {
                            if (context.mounted) _showError(context, error);
                          }
                        },
                      ),
                      Text(
                        reminder.isArrived
                            ? 'Triggered'
                            : reminder.isTracking
                            ? 'Active'
                            : 'Paused',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      reminder.place.displayLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: reminder.place.displayLabelDirection,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (reminder.isPinned) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      label: 'Pinned reminder',
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 12,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<_ReminderAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                reminder.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
              ),
              title: Text(
                reminder.isPinned ? 'Unpin reminder' : 'Pin reminder',
              ),
              onTap: () => Navigator.pop(context, _ReminderAction.pin),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Delete reminder'),
              onTap: () => Navigator.pop(context, _ReminderAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final state = context.read<AppController>();
    try {
      switch (action) {
        case _ReminderAction.pin:
          await state.setReminderPinned(reminder, !reminder.isPinned);
        case _ReminderAction.delete:
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
          if (confirmed == true) await state.deleteReminder(reminder);
      }
    } on Object catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  static String _distanceLabel(int meters) => meters < 1000
      ? '$meters m away'
      : '${(meters / 1000).toStringAsFixed(1)} km away';

  static String _bearingLabel(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((bearing + 22.5) ~/ 45) % directions.length];
  }
}

class _Compass extends StatelessWidget {
  const _Compass({
    required this.bearing,
    required this.deviceHeading,
    required this.color,
  });

  final double bearing;
  final ValueListenable<double?> deviceHeading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: deviceHeading,
      builder: (context, heading, _) {
        final direction = CompassService.directionTo(bearing, heading ?? 0);
        return Semantics(
          label: heading == null
              ? 'Destination bearing ${bearing.round() % 360} degrees'
              : _relativeDirectionLabel(direction),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: heading == null ? 0 : 3,
                  child: heading == null
                      ? Text(
                          'N',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                      : Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Transform.rotate(
                    angle: direction * math.pi / 180,
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 23,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _relativeDirectionLabel(double direction) {
    final rounded = direction.round() % 360;
    if (rounded == 0) return 'Destination straight ahead';
    if (rounded <= 180) {
      return 'Destination $rounded degrees to the right';
    }
    return 'Destination ${360 - rounded} degrees to the left';
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders({required this.hasAny});

  final bool hasAny;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasAny ? Icons.search_off_rounded : Icons.route_rounded,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            hasAny ? 'No matching reminders' : 'Your next stop starts here',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

void _showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(error.toString())));
}
