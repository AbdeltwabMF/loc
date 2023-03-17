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
            trailing: DropdownButton<String>(
              iconSize: 32,
              value: appStates.themeMode,
              items: <String>['System', 'Dark', 'Light'].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  appStates.setThemeMode(value);
                }
              },
            )),
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
