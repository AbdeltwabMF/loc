import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/pages/reminder_editor_page.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const guidancePreference = 'external_map_guidance_hidden';
  late Directory directory;
  late AppController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('loc_editor_test_');
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

  testWidgets('explains how to return a place from another map', (
    tester,
  ) async {
    await _pumpEditor(tester, controller);

    await tester.tap(find.text('Other map'));
    await tester.pumpAndSettle();

    expect(find.text('Choose in another map'), findsOneWidget);
    expect(find.text('Choose the destination'), findsOneWidget);
    expect(find.text('Tap Share'), findsOneWidget);
    expect(find.text('Select Loc'), findsOneWidget);
    expect(find.text("Don't show again"), findsOneWidget);
    expect(find.text('Open map'), findsOneWidget);
    // Numbered steps replace the old decorative connector lines/icons.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(
        of: dialog,
        matching: find.byIcon(Icons.location_on_outlined),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: dialog, matching: find.byIcon(Icons.share_outlined)),
      findsNothing,
    );
    final locIcon = tester.widget<Image>(
      find.descendant(of: dialog, matching: find.byType(Image)),
    );
    expect(
      (locIcon.image as AssetImage).assetName,
      'assets/icons/app_icon.png',
    );
    final theme = Theme.of(tester.element(dialog)).dialogTheme;
    final optOutLabel = tester.widget<Text>(find.text("Don't show again"));
    expect(theme.titleTextStyle?.fontSize, 24);
    expect(theme.titleTextStyle?.fontWeight, FontWeight.w400);
    expect(optOutLabel.style?.fontSize, 14);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.byType(TextButton)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: dialog, matching: find.byType(FilledButton)),
      findsNothing,
    );
  });

  testWidgets('persists the external map guidance opt-out', (tester) async {
    await _pumpEditor(tester, controller);

    await tester.tap(find.text('Other map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Don't show again"));
    await tester.tap(find.text('Open map'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(guidancePreference), isTrue);

    await tester.tap(find.text('Other map'));
    await tester.pumpAndSettle();

    expect(find.text('Choose in another map'), findsNothing);
  });

  testWidgets('describes alarm behavior without a channel settings action', (
    tester,
  ) async {
    await _pumpEditor(tester, controller);
    await tester.ensureVisible(find.text('Alarm'));
    await tester.tap(find.text('Alarm'));
    await tester.pump();

    expect(
      find.text('Repeats using your alarm volume until dismissed'),
      findsOneWidget,
    );
    expect(find.text('Alarm settings'), findsNothing);
  });

  testWidgets('adapts long labels to a narrow screen with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.reset);

    await _pumpEditor(
      tester,
      controller,
      locale: const Locale('pt'),
      textScaler: const TextScaler.linear(1.5),
    );

    final otherMapButton = find.ancestor(
      of: find.text('Outro mapa'),
      matching: find.byType(OutlinedButton),
    );
    final coordinatesButton = find.ancestor(
      of: find.text('Coordenadas'),
      matching: find.byType(OutlinedButton),
    );
    expect(
      tester.getTopLeft(coordinatesButton).dy,
      greaterThan(tester.getTopLeft(otherMapButton).dy),
    );

    final alertStyles = tester.widget<SegmentedButton<ReminderAlertStyle>>(
      find.byType(SegmentedButton<ReminderAlertStyle>),
    );
    expect(alertStyles.direction, Axis.vertical);
    expect(find.text('Vibração'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpEditor(
  WidgetTester tester,
  AppController controller, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.themeLight,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const ReminderEditorPage(),
      ),
    ),
  );
}
