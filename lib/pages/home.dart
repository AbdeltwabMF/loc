import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/pages/arrival_list.dart';
import 'package:loc/pages/favorites_list.dart';
import 'package:loc/pages/reminders_search.dart';
import 'package:loc/pages/settings.dart';
import 'package:loc/pages/about.dart';
import 'package:loc/pages/reminders_add.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/bottom_nav_bar.dart';
import 'package:loc/pages/reminders_list.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<Widget> _navWidgetList = [
    RemindersList(),
    FavoritesList(),
    ArrivalList(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        if (appStates.listening == false) {
          getCurrentLocation().then((value) {
            appStates.setCurrent(value.position);
            handlePositionUpdates(context);
            appStates.setListening(true);
          });
        }
        if (appStates.notify == true) {
          if (appStates.arrivalAll().isNotEmpty) {
            if (appStates.ringing == false) {
              FlutterRingtonePlayer.playAlarm(
                asAlarm: true,
                looping: true,
                volume: 1.0,
              );
              appStates.setRinging(true);
            }
          } else {
            if (appStates.ringing == true) {
              FlutterRingtonePlayer.stop();
              appStates.setRinging(false);
            }
          }
        }
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          appStates.reminderOptions == true
              ? IconButton(
                  onPressed: () {
                    appStates.favoriteAdd(
                        appStates.reminderRead(appStates.selected)!.place);
                  },
                  icon: const Icon(
                    Icons.favorite_rounded,
                    size: 32,
                  ),
                )
              : const SizedBox.shrink(),
          appStates.reminderOptions == true
              ? IconButton(
                  onPressed: () {
                    appStates.reminderDelete(appStates.selected);
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    size: 32,
                  ),
                )
              : const SizedBox.shrink(),
          appStates.reminderOptions == true
              ? IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 32,
                  ),
                )
              : const SizedBox.shrink(),
          appStates.reminderOptions == true
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return const RemindersSearch();
                        },
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 32,
                  ),
                ),
          appStates.reminderOptions == true
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return const AboutPage();
                        },
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.info_rounded,
                    size: 32,
                  ),
                ),
          appStates.reminderOptions == true
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    if (appStates.notify == true) {
                      FlutterRingtonePlayer.stop();
                      appStates.setRinging(false);
                      appStates.setNotify(false);
                    } else {
                      appStates.setNotify(true);
                    }
                  },
                  icon: Icon(
                    appStates.notify == true
                        ? Icons.alarm_on_rounded
                        : Icons.alarm_off_rounded,
                    color: appStates.notify == true
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onTertiary,
                    size: 32,
                  ),
                ),
        ],
        elevation: 0,
        leading: null,
        title: const Text(
          'Loc',
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      floatingActionButton: appStates.bottomNavBarIndex != 0
          ? null
          : FloatingActionButton(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return RemindersAdd();
                    },
                  ),
                );
              },
              child: const Icon(
                Icons.add_alarm_rounded,
              ),
            ),
      body: SafeArea(
        child: _navWidgetList.elementAt(appStates.bottomNavBarIndex),
      ),
    );
  }
}
