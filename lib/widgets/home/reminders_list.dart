import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/pages/add_reminder.dart';
import 'package:loc/utils/format_strings.dart';
import 'package:provider/provider.dart';

class RemindersList extends StatelessWidget {
  const RemindersList({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return ListView.builder(
      physics: const ScrollPhysics(),
      itemCount: appStates.reminderAll().length,
      itemBuilder: (context, index) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          final remainderDistance = appStates
              .reminderRead(index)!
              .remainderDistance(appStates.getCurrent());
          final radius = appStates.reminderRead(index)!.place.radius;
          if (remainderDistance <= radius!) {
            appStates.arrivedAdd(appStates.reminderRead(index)!);
          }
        });

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
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return AddReminderPage();
                  },
                ),
              );
            },
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
                          value: appStates
                              .reminderRead(index)!
                              .traveledDistancePercent(appStates.getCurrent()),
                        ),
                      ),
                    ),
                    Text(
                      intFormat(appStates
                          .reminderRead(index)!
                          .remainderDistance(appStates.getCurrent())
                          .round()),
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
                    appStates.reminderRead(index)!.title,
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
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    subtitle: Text(
                      '${appStates.reminderRead(index)!.place.position.latitude}, ${appStates.reminderRead(index)!.place.position.longitude}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Fantasque',
                        fontSize: 12,
                        height: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    title: Text(
                      appStates.reminderRead(index)!.place.displayName!,
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
    );
  }
}
