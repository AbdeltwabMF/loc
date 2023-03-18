import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return BottomNavigationBar(
      currentIndex: appStates.bottomNavBarIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_rounded,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.favorite_border_rounded,
          ),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.share_arrival_time_rounded,
          ),
          label: 'Arrival',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings_rounded,
          ),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        if (appStates.bottomNavBarIndex == index) return;
        appStates.setBottomNavBarIndex(index);
        appStates.selectedClear();
      },
      type: BottomNavigationBarType.fixed,
      unselectedFontSize: 14.0,
    );
  }
}
