import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:provider/provider.dart';

enum ReminderFilter { all, active, arrived, paused }

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String _query = '';
  ReminderFilter _filter = ReminderFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppController>();
    final reminders = state.reminders
        .where((item) {
          final query = _query.trim().toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              (item.place.displayName ?? '').toLowerCase().contains(query);
          final matchesFilter = switch (_filter) {
            ReminderFilter.active => item.isTracking,
            ReminderFilter.arrived => item.isArrived,
            ReminderFilter.paused => !item.isTracking,
            ReminderFilter.all => true,
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(state: state)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search your destinations',
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
                        label: Text(
                          filter.name[0].toUpperCase() +
                              filter.name.substring(1),
                        ),
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (state.locationError != null && state.activeCount > 0)
          SliverToBoxAdapter(
            child: _LocationWarning(message: state.locationError!),
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
              ),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AppController state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOC',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Know when you\'re there.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 9,
                  color: state.isTrackingLocation
                      ? colors.secondary
                      : colors.outline,
                ),
                const SizedBox(width: 7),
                Text('${state.activeCount} active'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.currentPosition});

  final Reminder reminder;
  final Point? currentPosition;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppController>();
    final position = currentPosition;
    final distance = position == null
        ? null
        : reminder.remainderDistance(position).round();
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ReminderEditorPage(reminder: reminder),
          ),
        ),
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
                          ? colors.tertiaryContainer
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      reminder.isArrived
                          ? Icons.flag_rounded
                          : Icons.location_on_rounded,
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
                              ? 'Inside arrival zone'
                              : distance == null
                              ? '${reminder.place.radius ?? 500} m radius'
                              : _distanceLabel(distance),
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
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
                ],
              ),
              const SizedBox(height: 14),
              Text(
                reminder.place.displayName ?? 'Dropped pin',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _distanceLabel(int meters) => meters < 1000
      ? '$meters m away'
      : '${(meters / 1000).toStringAsFixed(1)} km away';
}

class _LocationWarning extends StatelessWidget {
  const _LocationWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        leading: const Icon(Icons.location_disabled_rounded),
        title: const Text('Attention needed'),
        subtitle: Text(message),
        trailing: TextButton(
          onPressed: () async {
            try {
              await context.read<AppController>().startTracking();
            } on Object catch (error) {
              if (context.mounted) _showError(context, error);
            }
          },
          child: const Text('Retry'),
        ),
      ),
    ),
  );
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
          const SizedBox(height: 8),
          Text(
            hasAny
                ? 'Try a different search or filter.'
                : 'Create a destination and Loc will watch the distance for you.',
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
