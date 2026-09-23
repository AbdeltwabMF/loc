import 'package:flutter/material.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/text_direction.dart';
import 'package:provider/provider.dart';

class SavedPlacesPage extends StatelessWidget {
  const SavedPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final places = context.watch<AppController>().favorites;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Places',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Save destinations you use often.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (places.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyPlaces())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
            sliver: SliverList.separated(
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _PlaceCard(place: places[index]),
            ),
          ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: const Icon(Icons.bookmark_rounded),
      title: Text(
        place.displayName ?? 'Dropped pin',
        maxLines: 2,
        textDirection: textDirectionFor(place.displayName ?? 'Dropped pin'),
      ),
      subtitle: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          '${place.position.latitude.toStringAsFixed(5)}, '
          '${place.position.longitude.toStringAsFixed(5)}',
        ),
      ),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ReminderEditorPage(initialPlace: place),
        ),
      ),
      trailing: IconButton(
        tooltip: 'Remove saved place',
        onPressed: () => context.read<AppController>().deleteFavorite(place),
        icon: const Icon(Icons.close_rounded),
      ),
    ),
  );
}

class _EmptyPlaces extends StatelessWidget {
  const _EmptyPlaces();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_add_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved places yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Save a destination from a reminder to keep it close.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
