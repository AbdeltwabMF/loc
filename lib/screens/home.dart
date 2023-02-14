import 'package:flutter/material.dart';
import 'package:loc/screens/about.dart';
import 'package:loc/screens/new_reminder.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:loc/widgets/render_reminders.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);
    handlePositionUpdates(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Reminders',
        ),
        leading: null,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return const AboutScreen();
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.clear();
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) {
                return NewReminderScreen();
              },
            ),
          );
        },
        backgroundColor: AppColors.darkBlue,
        child: const Icon(
          Icons.add_alarm_rounded,
          color: AppColors.fg,
        ),
      ),
      body: SafeArea(
        child: provider.readAllReminders().isNotEmpty
            ? const RenderReminders()
            : Container(
                alignment: Alignment.center,
                child: const Text(
                  'No reminders yet',
                  style: TextStyle(
                    color: AppColors.bg1,
                    fontSize: 32,
                  ),
                ),
              ),
      ),
    );
  }
}
