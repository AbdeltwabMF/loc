import 'package:flutter/material.dart';
import 'package:loc/screens/new_reminder.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

class RenderReminders extends StatelessWidget {
  const RenderReminders({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: provider.readAllReminders().length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(
            top: 16,
            left: 2,
            right: 2,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return NewReminderScreen();
                  },
                ),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        minHeight: 24,
                        value: provider
                            .readReminder(index)!
                            .getTraveledDistancePercent(provider.getCurrent()),
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.bg1,
                    ),
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    width: double.infinity,
                    child: Text(
                      provider.readReminder(index)!.title,
                      style: const TextStyle(
                        color: AppColors.fg,
                        fontFamily: 'Fantasque',
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.bg1,
                    ),
                    child: ListTile(
                      shape:
                          const RoundedRectangleBorder(side: BorderSide.none),
                      subtitle: Text(
                        '${provider.readReminder(index)!.position.latitude}, ${provider.readReminder(index)!.position.longitude}',
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppColors.darkYellow,
                          fontFamily: 'Fantasque',
                          fontSize: 12,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      title: Text(
                        provider.readReminder(index)!.displayName ?? '',
                        maxLines: 2,
                        style: const TextStyle(
                          color: AppColors.fg,
                          fontFamily: 'NotoArabic',
                          fontSize: 16,
                          height: 1.5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Container(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_rounded,
                            color: AppColors.lightRed,
                            size: 32,
                          ),
                          onPressed: () {
                            provider.deleteReminder(index);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
