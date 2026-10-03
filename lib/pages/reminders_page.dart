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
import 'package:loc/themes/tokens.dart';
import 'package:loc/widgets/app_components.dart';
import 'package:provider/provider.dart';

enum ReminderFilter { all, pinned, active, arrived, paused }

enum _ReminderAction { pin, delete }

enum _ReminderMenuAction { settings, sourceCode, privacyPolicy, about }

class RemindersPage extends StatefulWidget {
  const RemindersPage({
    required this.onSettingsPressed,
    required this.onSourceCodePressed,
    required this.onPrivacyPolicyPressed,
    required this.onAboutPressed,
    super.key,
  });

  final VoidCallback onSettingsPressed;
  final VoidCallback onSourceCodePressed;
  final VoidCallback onPrivacyPolicyPressed;
  final VoidCallback onAboutPressed;

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
    if (_lifecycleState == AppLifecycleState.resumed) {
      _startCompass();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
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
    final textScaler = MediaQuery.textScalerOf(context);
    final headerExtent = math.max(
      180.0,
      math.max(48.0, textScaler.scale(24) * 32 / 24 + 8) +
          math.max(48.0, textScaler.scale(16) * 1.5 + 28) +
          16 +
          math.max(48.0, textScaler.scale(14) * 1.4 + 24),
    );

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ReminderHeaderDelegate(
            selectedFilter: _filter,
            extent: headerExtent,
            onSettingsPressed: widget.onSettingsPressed,
            onSourceCodePressed: widget.onSourceCodePressed,
            onPrivacyPolicyPressed: widget.onPrivacyPolicyPressed,
            onAboutPressed: widget.onAboutPressed,
            onQueryChanged: (value) => setState(() => _query = value),
            onFilterSelected: (filter) => setState(() => _filter = filter),
          ),
        ),
        if (reminders.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyReminders(hasAny: state.reminders.isNotEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.compact,
              AppSpacing.page,
              112,
            ),
            sliver: SliverList.separated(
              itemCount: reminders.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.compact),
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
}

class _ReminderHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ReminderHeaderDelegate({
    required this.selectedFilter,
    required this.extent,
    required this.onSettingsPressed,
    required this.onSourceCodePressed,
    required this.onPrivacyPolicyPressed,
    required this.onAboutPressed,
    required this.onQueryChanged,
    required this.onFilterSelected,
  });

  final ReminderFilter selectedFilter;
  final double extent;
  final VoidCallback onSettingsPressed;
  final VoidCallback onSourceCodePressed;
  final VoidCallback onPrivacyPolicyPressed;
  final VoidCallback onAboutPressed;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ReminderFilter> onFilterSelected;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    elevation: overlapsContent ? 1 : 0,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 4, 8, 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Reminders',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                PopupMenuButton<_ReminderMenuAction>(
                  tooltip: 'More options',
                  icon: const Icon(Icons.more_vert_rounded),
                  constraints: const BoxConstraints(
                    minWidth: 180,
                    maxWidth: 240,
                  ),
                  menuPadding: const EdgeInsets.symmetric(vertical: 6),
                  onSelected: (action) => switch (action) {
                    _ReminderMenuAction.settings => onSettingsPressed(),
                    _ReminderMenuAction.sourceCode => onSourceCodePressed(),
                    _ReminderMenuAction.privacyPolicy =>
                      onPrivacyPolicyPressed(),
                    _ReminderMenuAction.about => onAboutPressed(),
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _ReminderMenuAction.settings,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                      ),
                    ),
                    PopupMenuItem(
                      value: _ReminderMenuAction.sourceCode,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _MenuItem(
                        icon: Icons.code_rounded,
                        label: 'Source code',
                      ),
                    ),
                    PopupMenuItem(
                      value: _ReminderMenuAction.privacyPolicy,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _MenuItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy policy',
                      ),
                    ),
                    PopupMenuItem(
                      value: _ReminderMenuAction.about,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            4,
            AppSpacing.page,
            12,
          ),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search reminders',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          height: math.max(
            48,
            MediaQuery.textScalerOf(context).scale(14) * 1.4 + 24,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            scrollDirection: Axis.horizontal,
            itemCount: ReminderFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = ReminderFilter.values[index];
              return FilterChip(
                selected: selectedFilter == filter,
                label: Text(_filterLabel(filter)),
                showCheckmark: false,
                onSelected: (_) => onFilterSelected(filter),
              );
            },
          ),
        ),
      ],
    ),
  );

  @override
  bool shouldRebuild(_ReminderHeaderDelegate oldDelegate) =>
      selectedFilter != oldDelegate.selectedFilter ||
      extent != oldDelegate.extent ||
      onSettingsPressed != oldDelegate.onSettingsPressed ||
      onSourceCodePressed != oldDelegate.onSourceCodePressed ||
      onPrivacyPolicyPressed != oldDelegate.onPrivacyPolicyPressed ||
      onAboutPressed != oldDelegate.onAboutPressed;

  static String _filterLabel(ReminderFilter filter) => switch (filter) {
    ReminderFilter.all => 'All',
    ReminderFilter.pinned => 'Pinned',
    ReminderFilter.active => 'Active',
    ReminderFilter.arrived => 'Triggered',
    ReminderFilter.paused => 'Paused',
  };
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
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
    final theme = Theme.of(context);
    final marker = bearing == null
        ? Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: reminder.isArrived
                  ? colors.secondary
                  : colors.tertiaryContainer,
              borderRadius: AppRadius.cardRadius,
            ),
            child: Icon(
              reminder.isArrived
                  ? Icons.flag_rounded
                  : Icons.location_on_rounded,
              color: markerColor,
            ),
          )
        : _Compass(
            bearing: bearing,
            deviceHeading: deviceHeading,
            color: markerColor,
            backgroundColor: reminder.isArrived
                ? colors.secondary
                : colors.tertiaryContainer,
            alignedColor: colors.onPrimary,
            alignedBackgroundColor: colors.primary,
          );
    final rawPlaceLabel = reminder.place.displayLabel;
    final placeLabel = rawPlaceLabel == Place.droppedPinLabel
        ? '$rawPlaceLabel · ${reminder.place.coordinateLabel}'
        : rawPlaceLabel;

    return Card(
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ReminderEditorPage(reminder: reminder),
          ),
        ),
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      marker,
                      if (reminder.isPinned)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: Semantics(
                            label: 'Pinned reminder',
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary,
                                border: Border.all(
                                  color: colors.surfaceContainer,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distance == null
                              ? '${reminder.place.radius ?? Place.defaultRadius} m alert distance'
                              : '${_distanceLabel(distance)} · '
                                    '${_bearingLabel(bearing!)} '
                                    '${bearing.round() % 360}°',
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reminder.isArrived) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Triggered',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Semantics(
                    label: reminder.isTracking
                        ? 'Tracking enabled'
                        : 'Tracking paused',
                    child: CompactSwitch(
                      value: reminder.isTracking,
                      onChanged: (value) async {
                        try {
                          await state.setReminderTracking(reminder, value);
                        } on Object catch (error) {
                          if (context.mounted) _showError(context, error);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.compact),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      placeLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: reminder.place.displayLabelDirection,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reminder actions',
                    onPressed: () => _showActions(context),
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
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
              scrollable: true,
              title: const Text('Delete this reminder?'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
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
    required this.backgroundColor,
    required this.alignedColor,
    required this.alignedBackgroundColor,
  });

  final double bearing;
  final ValueListenable<double?> deviceHeading;
  final Color color;
  final Color backgroundColor;
  final Color alignedColor;
  final Color alignedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: deviceHeading,
      builder: (context, heading, _) {
        final direction = CompassService.directionTo(bearing, heading ?? 0);
        final aligned = heading != null && CompassService.isAligned(direction);
        final foreground = aligned ? alignedColor : color;
        return Semantics(
          label: heading == null
              ? 'Destination bearing ${bearing.round() % 360} degrees'
              : aligned
              ? 'Destination straight ahead'
              : _relativeDirectionLabel(direction),
          child: AnimatedContainer(
            width: 46,
            height: 46,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: aligned ? alignedBackgroundColor : backgroundColor,
              borderRadius: AppRadius.cardRadius,
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: foreground, width: 1.5),
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
                                  color: foreground,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                          )
                        : Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: foreground,
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
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
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
