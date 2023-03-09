import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/pages/arrival_list.dart';
import 'package:loc/pages/favorites_list.dart';
import 'package:loc/pages/reminders_search.dart';
import 'package:loc/pages/settings.dart';
import 'package:loc/pages/about.dart';
import 'package:loc/pages/reminders_add.dart';
import 'package:loc/utils/database_ops.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/bottom_nav_bar.dart';
import 'package:loc/pages/reminders_list.dart';
import 'package:rive/rive.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> with WidgetsBindingObserver {
  static const List<Widget> _navWidgetList = [
    RemindersList(),
    FavoritesList(),
    ArrivalList(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    writeData(context);
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        readData(context);
        break;
      case AppLifecycleState.paused:
        writeData(context);
        break;
      case AppLifecycleState.detached:
        writeData(context);
        break;
      default:
        break;
    }
  }

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

        if (appStates.loaded == false) {
          readData(context);
          appStates.setLoaded(true);
        }

        if (appStates.notify == true) {
          if (appStates.arrivalAll().isNotEmpty) {
            if (appStates.reminderAll().isEmpty) {
              FlutterRingtonePlayer.stop();
              appStates.setRinging(false);
            } else {
              if (appStates.ringing == false) {
                FlutterRingtonePlayer.playAlarm(
                  asAlarm: true,
                  looping: true,
                  volume: 1.0,
                );
                appStates.setRinging(true);
              }
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

    return WillPopScope(
      onWillPop: () async {
        if (appStates.reminderOptions == true) {
          appStates.setReminderOptions(false);
          return false;
        }
        writeData(context);
        return true;
      },
      child: Stack(
        children: [
          const Positioned.fill(
            child: RiveAnimation.asset(
              'assets/raw/fanoos.riv',
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Scaffold(
              backgroundColor:
                  Theme.of(context).colorScheme.background.withOpacity(0.8),
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                actions: [
                  appStates.reminderOptions == true
                      ? IconButton(
                          onPressed: () {
                            appStates.favoriteAdd(appStates
                                .reminderRead(appStates.selected)!
                                .place);
                            appStates.setReminderOptions(false);
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
                            appStates.setReminderOptions(false);
                          },
                          icon: const Icon(
                            Icons.delete_rounded,
                            size: 32,
                          ),
                        )
                      : const SizedBox.shrink(),
                  appStates.reminderOptions == true
                      ? IconButton(
                          onPressed: () {
                            appStates.setReminderOptions(false);
                          },
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: 32,
                          ),
                        )
                      : const SizedBox.shrink(),
                  appStates.reminderOptions == true
                      ? const SizedBox.shrink()
                      : appStates.bottomNavBarIndex != 3
                          ? IconButton(
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
                            )
                          : const SizedBox.shrink(),
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
                ],
                elevation: 0,
                leading: null,
                title: appStates.reminderOptions == true
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 32,
                        ),
                        onPressed: () {
                          appStates.setReminderOptions(false);
                        },
                      )
                    : const Text(
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
                              return const RemindersAdd();
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
            ),
          ),
        ],
      ),
    );
  }
}
