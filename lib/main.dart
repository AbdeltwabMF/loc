import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/app_locale_service.dart';
import 'package:loc/data/services/background_tracking_service.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/l10n/l10n.dart';
import 'package:loc/pages/home.dart';
import 'package:loc/pages/permission_setup_page.dart';
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

  final repository = AppRepository(
    await Hive.openBox<dynamic>('reminders'),
    await Hive.openBox<dynamic>('settings'),
  );

  await reconcileBackgroundTracking(repository);

  final platformLocale = await AppLocaleService.getApplicationLocale();
  if (platformLocale.supported) {
    await repository.saveLocaleCode(platformLocale.languageCode);
  }
  final localeCode = repository.loadLocaleCode();
  final initialLocalizations = await loadAppLocalizations(localeCode);
  if (localeCode != null) {
    await AppLocaleService.setApplicationLocale(localeCode);
  }
  final notificationService = NotificationService();
  await notificationService.initialize(
    content: NotificationContent.fromLocalizations(initialLocalizations),
  );
  try {
    await initializeBackgroundTracking();
  } on Object {
    // Foreground UI tracking still works; screen-off tracking is best-effort.
  }

  final controller = AppController(
    repository: repository,
    locationService: LocationService(),
    notificationService: notificationService,
    backgroundTracking: FlutterBackgroundTrackingControl(),
  );

  await controller.initialize();
  runApp(LocApp(controller: controller));
}

class LocApp extends StatefulWidget {
  const LocApp({required this.controller, super.key});

  final AppController controller;

  @override
  State<LocApp> createState() => _LocAppState();
}

class _LocAppState extends State<LocApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    unawaited(
      widget.controller.refreshSystemLocale().onError(
        (Object _, StackTrace _) {},
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => widget.controller,
      child: Consumer<AppController>(
        builder: (context, state, child) {
          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.appName,
            debugShowCheckedModeBanner: false,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(
              useSystemFont: state.useSystemFont,
              languageCode: state.effectiveLanguageCode,
            ),
            darkTheme: AppTheme.dark(
              useSystemFont: state.useSystemFont,
              languageCode: state.effectiveLanguageCode,
            ),
            themeMode: state.themeMode,
            home: !state.trackingSetupSeen || state.permissionRecoveryRequired
                ? PermissionSetupPage(initialSetup: !state.trackingSetupSeen)
                : const HomePage(),
          );
        },
      ),
    );
  }
}
