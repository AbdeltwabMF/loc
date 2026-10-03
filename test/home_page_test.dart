import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/pages/home.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';

void main() {
  late Directory directory;
  late AppController controller;

  setUpAll(() {
    AppMetadata.current = const AppMetadata(
      version: '2.1.0',
      buildNumber: '107',
    );
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loc_home_test_');
    Hive.init(directory.path);
    controller = AppController(
      repository: AppRepository(
        await Hive.openBox<dynamic>('reminders'),
        await Hive.openBox<dynamic>('preferences'),
      ),
      locationService: LocationService(),
      notificationService: NotificationService(),
    );
  });

  tearDown(() async {
    controller.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets('shows overflow menu above search without bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(theme: AppTheme.themeLight, home: const HomePage()),
      ),
    );

    final title = find.text('Reminders');
    final menu = find.byTooltip('More options');
    final search = find.widgetWithText(TextField, 'Search reminders');

    expect(find.byType(NavigationBar), findsNothing);
    expect(title, findsOneWidget);
    expect(menu, findsOneWidget);
    expect(search, findsOneWidget);
    expect(tester.getTopLeft(title).dy, lessThan(tester.getTopLeft(search).dy));
    expect(tester.getTopLeft(menu).dy, lessThan(tester.getTopLeft(search).dy));
  });

  testWidgets('shows app actions and version from the overflow menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(theme: AppTheme.themeLight, home: const HomePage()),
      ),
    );

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Source code'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.code_rounded), findsOneWidget);
    expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    final menu = tester.widget<PopupMenuButton<dynamic>>(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    expect(menu.constraints?.minWidth, 180);
    expect(menu.constraints?.maxWidth, 240);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.text('Loc'), findsOneWidget);
    expect(find.text('2.1.0 (107)'), findsOneWidget);
    expect(find.text('Licensed under GPL-3.0'), findsOneWidget);
    expect(find.text('View licenses'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    final icon = tester.widget<Image>(
      find.descendant(
        of: find.byType(AboutDialog),
        matching: find.byType(Image),
      ),
    );
    expect(icon.width, 48);
    expect(icon.height, 48);

    await tester.tap(find.text('View licenses'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
