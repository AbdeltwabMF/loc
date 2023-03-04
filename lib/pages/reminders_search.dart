import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/utils/format_strings.dart';
import 'package:provider/provider.dart';

class RemindersSearch extends StatefulWidget {
  const RemindersSearch({super.key});

  @override
  State<RemindersSearch> createState() => _RemindersSearch();
}

class _RemindersSearch extends State<RemindersSearch> {
  final _search = TextEditingController();
  List<Reminder> _matched = <Reminder>[];

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _search,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search...',
            isDense: true,
          ),
          onChanged: (value) {
            final reminders = appStates.reminderAll();
            final matched = <Reminder>[];
            for (int i = 0; i < reminders.length; ++i) {
              if (reminders[i].title.contains(value)) {
                matched.add(reminders[i]);
              } else if (reminders[i].place.displayName != null &&
                  reminders[i].place.displayName!.contains(value)) {
                matched.add(reminders[i]);
              } else if (reminders[i].notes != null &&
                  reminders[i].notes!.contains(value)) {
                matched.add(reminders[i]);
              }
            }
            if (mounted) {
              setState(() {
                _matched = matched;
              });
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _matched.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: GestureDetector(
              onTap: () {},
              onLongPress: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          ),
                          child: LinearProgressIndicator(
                            minHeight: 26,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            color: Theme.of(context).colorScheme.tertiary,
                            value: _matched[index].traveledDistancePercent(
                                appStates.getCurrent()),
                          ),
                        ),
                      ),
                      Text(
                        '${intFormat(_matched[index].remainderDistance(appStates.getCurrent()).round())} meters away',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    width: double.infinity,
                    child: Text(
                      _matched[index].title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                    ),
                    decoration: const BoxDecoration(),
                    child: ListTile(
                      shape:
                          const RoundedRectangleBorder(side: BorderSide.none),
                      subtitle: Text(
                        '${_matched[index].place.position.latitude}, ${_matched[index].place.position.longitude}',
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'Fantasque',
                          fontSize: 12,
                          height: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      title: Text(
                        _matched[index].place.displayName!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'NotoArabic',
                          fontSize: 16,
                          height: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
