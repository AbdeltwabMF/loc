import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/data/services/power_service.dart';
import 'package:loc/pages/permission_setup_page.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';

void main() {
  late AppController controller;
  late _FakeRepository repository;
  late _FakeLocationService location;

  setUp(() async {
    repository = _FakeRepository();
    location = _FakeLocationService();
    controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: _FakeNotificationService(),
    );
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  testWidgets('presents required and optional access without dialogs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.themeLight,
          home: PermissionSetupPage(
            initialSetup: true,
            powerService: _FakePowerService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set up permissions'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Screen-off tracking'), findsOneWidget);
    expect(find.text('Battery access', skipOffstage: false), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.scrollUntilVisible(find.text('Continue'), 300);
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(repository.trackingSetupSeen, isTrue);
  });

  testWidgets('active-reminder recovery presents the full permission list', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.themeLight,
          home: const PermissionSetupPage(initialSetup: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Location access needed'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Screen-off tracking'), findsOneWidget);
    expect(find.text('Battery access', skipOffstage: false), findsOneWidget);
  });

  testWidgets('explains how to grant background location before settings', (
    tester,
  ) async {
    location.failBackgroundRequest = true;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.themeLight,
          home: PermissionSetupPage(
            initialSetup: true,
            powerService: _FakePowerService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    final screenOffCard = find.ancestor(
      of: find.text('Screen-off tracking'),
      matching: find.byType(Card),
    );
    final allowButton = find.descendant(
      of: screenOffCard,
      matching: find.text('Allow'),
    );
    await tester.tap(allowButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Permissions > Location'), findsOneWidget);
    expect(location.appSettingsOpens, 0);

    await tester.tap(find.text('Open settings'));
    await tester.pump();

    expect(location.appSettingsOpens, 1);

    location
      ..backgroundPermissionGranted = true
      ..failBackgroundRequest = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(controller.backgroundTrackingEnabled, isTrue);
    expect(repository.backgroundTrackingEnabled, isTrue);
  });

  testWidgets('enables tracking when background permission already exists', (
    tester,
  ) async {
    controller.dispose();
    location = _FakeLocationService(hasBackgroundPermission: true);
    controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: _FakeNotificationService(),
    );
    await controller.initialize();
    expect(controller.backgroundLocationAllowed, isTrue);
    expect(controller.backgroundTrackingEnabled, isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.themeLight,
          home: PermissionSetupPage(
            initialSetup: true,
            powerService: _FakePowerService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    final screenOffCard = find.ancestor(
      of: find.text('Screen-off tracking'),
      matching: find.byType(Card),
    );
    final allowButton = find.descendant(
      of: screenOffCard,
      matching: find.text('Allow'),
    );
    await tester.tap(allowButton);
    await tester.pumpAndSettle();

    expect(controller.backgroundTrackingEnabled, isTrue);
    expect(repository.backgroundTrackingEnabled, isTrue);
  });

  testWidgets('enables arrival alerts when notification permission exists', (
    tester,
  ) async {
    controller.dispose();
    repository.alarmEnabled = false;
    controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: _FakeNotificationService(permissionGranted: true),
    );
    await controller.initialize();
    expect(controller.notificationsAllowed, isTrue);
    expect(controller.systemNotificationsEnabled, isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.themeLight,
          home: PermissionSetupPage(
            initialSetup: true,
            powerService: _FakePowerService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final notificationsCard = find.ancestor(
      of: find.text('Notifications'),
      matching: find.byType(Card),
    );
    await tester.ensureVisible(notificationsCard);
    await tester.tap(
      find.descendant(of: notificationsCard, matching: find.text('Allow')),
    );
    await tester.pumpAndSettle();

    expect(controller.systemNotificationsEnabled, isTrue);
    expect(repository.alarmEnabled, isTrue);
  });
}

class _FakeRepository implements AppRepository {
  bool trackingSetupSeen = false;
  bool backgroundTrackingEnabled = false;
  bool alarmEnabled = true;

  @override
  Future<void> deleteReminder(String id) async {}

  @override
  bool loadAlarmEnabled() => alarmEnabled;

  @override
  bool loadBackgroundTrackingEnabled() => backgroundTrackingEnabled;

  @override
  List<Reminder> loadReminders() => const [];

  @override
  bool loadTrackingSetupSeen() => trackingSetupSeen;

  @override
  String loadThemeMode() => 'system';

  @override
  bool loadUseGoogleSans() => true;

  @override
  Future<void> saveAlarmEnabled(bool value) async {
    alarmEnabled = value;
  }

  @override
  Future<void> saveBackgroundTrackingEnabled(bool value) async {
    backgroundTrackingEnabled = value;
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {}

  @override
  Future<void> saveThemeMode(String value) async {}

  @override
  Future<void> saveTrackingSetupSeen(bool value) async {
    trackingSetupSeen = value;
  }

  @override
  Future<void> saveUseGoogleSans(bool value) async {}
}

class _FakeNotificationService implements NotificationService {
  _FakeNotificationService({this.permissionGranted = false});

  bool permissionGranted;

  @override
  Future<void> dismissArrival() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isPermissionGranted() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    permissionGranted = true;
    return true;
  }

  @override
  Future<void> showArrival({
    required String title,
    required String body,
    required bool isAlarm,
    required bool isVibration,
  }) async {}
}

class _FakeLocationService implements LocationService {
  _FakeLocationService({bool hasBackgroundPermission = false})
    : backgroundPermissionGranted = hasBackgroundPermission;

  bool backgroundPermissionGranted;
  bool failBackgroundRequest = false;
  int appSettingsOpens = 0;

  @override
  Future<LocationAccessStatus> accessStatus({bool background = true}) async =>
      background && !backgroundPermissionGranted
      ? LocationAccessStatus.settingsRequired
      : LocationAccessStatus.ready;

  @override
  Future<Point> current() async => Point(latitude: 0, longitude: 0);

  @override
  Future<void> ensurePermission({bool background = false}) async {
    if (background && failBackgroundRequest) {
      throw const LocationException(
        'Allow location all the time for screen-off tracking.',
      );
    }
  }

  @override
  Future<bool> hasBackgroundPermission() async => backgroundPermissionGranted;

  @override
  Future<bool> openAppSettings() async {
    appSettingsOpens++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<Point> get updates => const Stream.empty();
}

class _FakePowerService implements PowerService {
  @override
  Future<bool> isBatteryExempt() async => false;

  @override
  Future<bool> requestBatteryExemption() async => true;
}
