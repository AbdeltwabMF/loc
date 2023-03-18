import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/widgets/place_holders.dart';
import 'package:provider/provider.dart';

class ArrivalList extends StatelessWidget {
  const ArrivalList({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return appStates.arrivalAll().isEmpty
        ? const EmptySpace(comment: 'Empty arrival list')
        : ListView.builder(
            itemCount: appStates.arrivalAll().length,
            addAutomaticKeepAlives: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.check_rounded,
                    size: 32,
                  ),
                  subtitle: Text(
                    appStates.arrivalAll().elementAt(index).place.displayName ??
                        '',
                    style: const TextStyle(
                      fontFamily: 'Fantasque',
                    ),
                  ),
                  title: Text(
                    appStates.arrivalAll().elementAt(index).title,
                    style: const TextStyle(
                      fontFamily: 'NotoArabic',
                    ),
                  ),
                ),
              );
            },
          );
  }
}
