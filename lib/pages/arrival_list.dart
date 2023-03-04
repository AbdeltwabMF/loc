import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/widgets/empty_plce_holder.dart';
import 'package:provider/provider.dart';

class ArrivalList extends StatelessWidget {
  const ArrivalList({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return appStates.reminderAll().isEmpty
        ? const EmptyPlaceHolder(comment: 'Arrival list is empty')
        : ListView.builder(
            itemCount: appStates.arrivalAll().length,
            addAutomaticKeepAlives: true,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                dense: true,
                leading: const Icon(
                  Icons.check_rounded,
                  size: 32,
                ),
                subtitle: Text(
                  appStates
                          .reminderFromId(
                              appStates.arrivalAll().elementAt(index))!
                          .place
                          .displayName ??
                      '',
                  style: const TextStyle(
                    fontFamily: 'Fantasque',
                  ),
                ),
                title: Text(
                  appStates
                      .reminderFromId(appStates.arrivalAll().elementAt(index))!
                      .title,
                  style: const TextStyle(
                    fontFamily: 'NotoArabic',
                  ),
                ),
              );
            },
          );
  }
}
