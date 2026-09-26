import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/geo_uri_service.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/pages/home.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppMetadata.initialize();
  await Hive.initFlutter('loc_db');
  Hive
    ..registerAdapter(ReminderAdapter())
    ..registerAdapter(PlaceAdapter())
    ..registerAdapter(PointAdapter());

  try {
    if (await Hive.boxExists('places')) {
      await Hive.deleteBoxFromDisk('places');
    }
  } on Object {
    // Obsolete saved-place data must not prevent the app from starting.
  }

  final repository = AppRepository(
    await Hive.openBox<dynamic>('reminders'),
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
          theme: AppTheme.themeLight,
          darkTheme: AppTheme.themeDark,
          themeMode: state.themeMode,
          home: const HomePage(),
          builder: (context, child) => Stack(
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox.shrink(),
              ValueListenableBuilder(
                valueListenable: GeoUriService.isResolving,
                builder: (context, isResolving, _) => isResolving
                    ? const _SharedLocationProgress()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedLocationProgress extends StatelessWidget {
  const _SharedLocationProgress();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 3,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 12),
                  Text('Retrieving shared location…'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
