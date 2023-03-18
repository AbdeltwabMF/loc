import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/utils/format.dart';
import 'package:provider/provider.dart';

class RemindersSearch extends StatefulWidget {
  const RemindersSearch({super.key});

  @override
  State<RemindersSearch> createState() => _RemindersSearch();
}

class _RemindersSearch extends State<RemindersSearch> {
  final _search = TextEditingController();
  List<Reminder> _matched = <Reminder>[];
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          focusNode: _focusNode,
          controller: _search,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search...',
            isDense: true,
            suffix: IconButton(
              onPressed: () {
                _search.clear();
              },
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
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
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.location_pin,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                subtitle: Text(
                  _matched[index].place.displayName!,
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: 'Fantasque',
                  ),
                ),
                title: Text(
                  _matched[index].title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'NotoArabic',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
