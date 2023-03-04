import 'package:flutter/material.dart';
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
          subtitle: const Text(
              'Choose between dark, light, and system. Initial is \'system\'.'),
          title: const Text('Theme Mode'),
          trailing: DropdownMenu<ThemeMode>(
            initialSelection: appStates.themeMode,
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              isDense: true,
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
            },
            value: appStates.notify,
          ),
        ),
      ],
    );
  }
}
