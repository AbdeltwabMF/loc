import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return ListView(
      children: [
        ListTile(
          dense: true,
          subtitle: const Text('Set theme mode globally.'),
          title: const Text('Theme Mode'),
          trailing: DropdownMenu<ThemeMode>(
            initialSelection: appStates.themeMode,
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              isDense: true,
            ),
            menuStyle: MenuStyle(
              side: MaterialStateProperty.all(BorderSide.none),
            ),
            onSelected: (value) {
              if (value != null) {
                appStates.setThemeMode(value);
              }
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: ThemeMode.system,
                label: 'system',
              ),
              DropdownMenuEntry(
                value: ThemeMode.dark,
                label: 'dark',
              ),
              DropdownMenuEntry(
                value: ThemeMode.light,
                label: 'light',
              ),
            ],
          ),
        ),
        ListTile(
          dense: true,
          subtitle: const Text('Turn alarm on/off globally'),
          title: const Text('Alarm'),
          trailing: Switch(
            onChanged: (value) {
              appStates.setNotify(value);
              if (value == false) {
                FlutterRingtonePlayer.stop();
                appStates.setRinging(false);
                appStates.setNotify(false);
              } else {
                appStates.setNotify(true);
              }
            },
            value: appStates.notify,
          ),
        ),
      ],
    );
  }
}
