import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/pages/home.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('loc_db');
  Hive
    ..registerAdapter(ReminderAdapter())
    ..registerAdapter(PlaceAdapter())
    ..registerAdapter(PointAdapter());

  final repository = AppRepository(
    await Hive.openBox<dynamic>('reminders'),
    await Hive.openBox<dynamic>('favorites'),
    await Hive.openBox<dynamic>('settings'),
  );
  await repository.migrateLegacyData();
  final notificationService = NotificationService();
  await notificationService.initialize();
  final controller = AppController(
    repository: repository,
    locationService: LocationService(),
    notificationService: notificationService,
  );
  await controller.initialize();
  runApp(LocApp(controller: controller));
}

class LocApp extends StatelessWidget {
  const LocApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller,
      child: Consumer<AppController>(
        builder: (context, state, child) => MaterialApp(
          title: 'Loc',
          debugShowCheckedModeBanner: false,
          theme: LocTheme.light,
          darkTheme: LocTheme.dark,
          themeMode: state.themeMode,
          home: const HomePage(),
        ),
      ),
    );
  }
}
