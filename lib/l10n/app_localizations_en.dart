// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Loc';

  @override
  String get appIconSemanticLabel => 'Loc icon';

  @override
  String get newReminderTooltip => 'New reminder';

  @override
  String get linkOpenError => 'Could not open that link.';

  @override
  String get licenseGpl3 => 'Licensed under GPL-3.0';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get moreOptionsTooltip => 'More options';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sourceCode => 'Source code';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get aboutApp => 'About';

  @override
  String get searchRemindersHint => 'Search reminders';

  @override
  String get filterAll => 'All';

  @override
  String get filterPinned => 'Pinned';

  @override
  String get filterActive => 'Active';

  @override
  String get filterTriggered => 'In range';

  @override
  String get filterPaused => 'Paused';

  @override
  String get pinnedReminderSemanticLabel => 'Pinned reminder';

  @override
  String alertDistanceMeters(int meters) {
    return '$meters m alert distance';
  }

  @override
  String get reminderStatusTriggered => 'In range';

  @override
  String get trackingEnabledSemanticLabel => 'Tracking enabled';

  @override
  String get trackingPausedSemanticLabel => 'Tracking paused';

  @override
  String get unpinReminder => 'Unpin reminder';

  @override
  String get pinReminder => 'Pin reminder';

  @override
  String get deleteReminder => 'Delete reminder';

  @override
  String get deleteReminderConfirmationTitle => 'Delete this reminder?';

  @override
  String get actionCannotBeUndone => 'This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String distanceMetersAway(int meters) {
    return '$meters m away';
  }

  @override
  String distanceKilometersAway(String kilometers) {
    return '$kilometers km away';
  }

  @override
  String get directionNorthShort => 'N';

  @override
  String get directionNorthEastShort => 'NE';

  @override
  String get directionEastShort => 'E';

  @override
  String get directionSouthEastShort => 'SE';

  @override
  String get directionSouthShort => 'S';

  @override
  String get directionSouthWestShort => 'SW';

  @override
  String get directionWestShort => 'W';

  @override
  String get directionNorthWestShort => 'NW';

  @override
  String destinationBearingDegrees(int degrees) {
    return 'Destination bearing $degrees degrees';
  }

  @override
  String get destinationStraightAhead => 'Destination straight ahead';

  @override
  String destinationDegreesRight(int degrees) {
    return 'Destination $degrees degrees to the right';
  }

  @override
  String destinationDegreesLeft(int degrees) {
    return 'Destination $degrees degrees to the left';
  }

  @override
  String get noMatchingReminders => 'No matching reminders';

  @override
  String get emptyRemindersMessage => 'Your next stop starts here';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get droppedPinLabel => 'Dropped pin';

  @override
  String placeWithCoordinates(String place, String coordinates) {
    return '$place · $coordinates';
  }

  @override
  String get trackingAccessHeading => 'Tracking access';

  @override
  String get arrivalNotifications => 'Arrival notifications';

  @override
  String get arrivalNotificationsEnabledDescription =>
      'Notify me when I arrive';

  @override
  String get allowNotificationsPrompt => 'Tap to allow notifications';

  @override
  String get screenOffTracking => 'Screen-off tracking';

  @override
  String get checkingLocationStatus => 'Checking Location status…';

  @override
  String get screenOffTrackingDescription =>
      'Continue tracking when the screen is off';

  @override
  String get locationServiceRequired => 'Requires Location to be on';

  @override
  String get allowLocationAllTheTimeTitle => 'Allow location all the time';

  @override
  String get allowLocationAllTheTimeInstructions =>
      'Tap here, then open Permissions > Location, select “Allow all the time”';

  @override
  String get batteryOptimizationOnTitle => 'Battery optimization is on';

  @override
  String get disableBatteryRestrictionsDescription =>
      'Turn off battery restrictions for reliable screen-off tracking';

  @override
  String get appearanceHeading => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get fontGoogleSans => 'Google Sans';

  @override
  String get fontBalooBhaijaan2 => 'Baloo Bhaijaan 2';

  @override
  String get useSystemFont => 'Use system font';

  @override
  String get systemFontDescription => 'Use the device\'s default font';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get newReminderTitle => 'New reminder';

  @override
  String get editReminderTitle => 'Edit reminder';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get alertLabel => 'Alert';

  @override
  String get notifyWithinLabel => 'Notify me when I’m within';

  @override
  String get alertStyleSound => 'Sound';

  @override
  String get alertStyleVibrate => 'Vibrate';

  @override
  String get alertStyleAlarm => 'Alarm';

  @override
  String get alertStyleSoundDescription => 'Plays a notification sound once';

  @override
  String get alertStyleVibrateDescription => 'Vibrates without playing a sound';

  @override
  String get alertStyleAlarmDescription =>
      'Repeats using your alarm volume until dismissed';

  @override
  String get retrievingLocationAddress => 'Retrieving location address…';

  @override
  String get savingLabel => 'Saving…';

  @override
  String get createReminderAction => 'Create reminder';

  @override
  String get saveChangesAction => 'Save changes';

  @override
  String get otherMapAction => 'Other map';

  @override
  String get hideCoordinatesAction => 'Hide coords';

  @override
  String get coordinatesShortLabel => 'Coords';

  @override
  String get reminderNameLabel => 'Reminder name';

  @override
  String get reminderNameHint => 'Central station';

  @override
  String get clearReminderNameTooltip => 'Clear reminder name';

  @override
  String get reminderNameRequiredError => 'Enter a reminder name';

  @override
  String get changeAction => 'Change';

  @override
  String get chooseOnMapAction => 'Choose on map';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String coordinateRangeError(String minimum, String maximum) {
    return '$minimum to $maximum';
  }

  @override
  String distanceMetersShort(int meters) {
    return '$meters m';
  }

  @override
  String distanceKilometersShort(String kilometers) {
    return '$kilometers km';
  }

  @override
  String distanceMetersSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meters',
      one: '1 meter',
    );
    return '$_temp0';
  }

  @override
  String distanceKilometersSemantic(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kilometers',
      one: '1 kilometer',
    );
    return '$_temp0';
  }

  @override
  String get chooseInAnotherMapTitle => 'Choose in another map';

  @override
  String get externalMapStepChooseDestination => 'Choose the destination';

  @override
  String get externalMapStepTapShare => 'Tap Share';

  @override
  String get externalMapStepSelectLoc => 'Select Loc';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get openMapAction => 'Open map';

  @override
  String get noCompatibleMapAppError => 'No compatible map app is installed';

  @override
  String get destinationRequiredError =>
      'Choose a destination or enter valid coordinates';

  @override
  String get reminderNotSavedTitle => 'Reminder was not saved';

  @override
  String get reminderNotSavedMessage =>
      'Your entries are still here. Check your connection and try again.';

  @override
  String get keepEditingAction => 'Keep editing';

  @override
  String get chooseDestinationTitle => 'Choose destination';

  @override
  String get mapPickerInstructions => 'Pan and zoom the map under the pin';

  @override
  String get mapTilesUnavailableMessage =>
      'Map tiles are unavailable. You can still choose a location.';

  @override
  String get openStreetMapAttribution => '© OpenStreetMap contributors';

  @override
  String get myLocationTooltip => 'My location';

  @override
  String get findingAddress => 'Finding address…';

  @override
  String get useThisLocationAction => 'Use this location';

  @override
  String get allowLocationAccessTitle => 'Allow location access';

  @override
  String get mapLocationPermissionMessage =>
      'Loc needs your permission to center the map where you are.';

  @override
  String get allowAction => 'Allow';

  @override
  String get enableLocationInAndroidSettingsMessage =>
      'Enable location permission for Loc in Android settings.';

  @override
  String get openSettingsAction => 'Open settings';

  @override
  String get notNowAction => 'Not now';

  @override
  String get locationUnknownError =>
      'Could not determine your location. Please try again.';

  @override
  String get permissionSetupTitle => 'Set up permissions';

  @override
  String get locationAccessNeededTitle => 'Restore access';

  @override
  String get permissionSetupDescription =>
      'Loc needs the following permissions';

  @override
  String get locationRecoveryDescription =>
      'Required permissions or device settings are disabled';

  @override
  String get requiredPermissionsHeading => 'Required';

  @override
  String get locationPermissionTitle => 'Location';

  @override
  String get locationPermissionDescription =>
      'To detect when you arrive at your destination';

  @override
  String get turnOnAction => 'Turn on';

  @override
  String get optionalPermissionsHeading => 'Optional';

  @override
  String get notificationsPermissionTitle => 'Notifications';

  @override
  String get notificationsPermissionDescription =>
      'To notify you when you arrive';

  @override
  String get backgroundLocationSettingsInstruction =>
      'In Permissions > Location, select “Allow all the time”';

  @override
  String get screenOffTrackingPermissionDescription =>
      'To keep reminders active when your screen is off';

  @override
  String get batteryAccessTitle => 'Battery access';

  @override
  String get batteryAccessDescription =>
      'To keep active reminders running reliably';

  @override
  String get continueAction => 'Continue';

  @override
  String get resumeRemindersAction => 'Resume reminders';

  @override
  String get optionalPermissionsSettingsNote =>
      'You can change optional permissions later in Settings';

  @override
  String get arrivalAlarmsChannelName => 'Arrival alarms';

  @override
  String get arrivalAlarmsChannelDescription =>
      'Repeating alarms for destinations that must wake you.';

  @override
  String get arrivalVibrationsChannelName => 'Arrival vibrations';

  @override
  String get arrivalVibrationsChannelDescription =>
      'Silent vibration alerts when an active destination is reached.';

  @override
  String get arrivalRemindersChannelName => 'Arrival reminders';

  @override
  String get arrivalRemindersChannelDescription =>
      'Brief alerts when an active destination is reached.';

  @override
  String get backgroundTrackingNotificationTitle =>
      'Loc is watching your route';

  @override
  String get backgroundTrackingNotificationBody =>
      'Active arrival reminders are being checked.';

  @override
  String get arrivalNotificationTitle => 'You have arrived';

  @override
  String get locationAccessBlockedError =>
      'Location access is blocked. Enable it in Android settings.';

  @override
  String get locationAccessNotGrantedError =>
      'Location access was not granted.';

  @override
  String get deviceLocationDisabledError =>
      'Turn on device location to track reminders.';

  @override
  String get backgroundLocationRequiredError =>
      'Allow location all the time so reminders work while the screen is off.';

  @override
  String get activeRemindersLocationRequiredError =>
      'Location access is required for active reminders.';

  @override
  String get enableActiveRemindersLocationError =>
      'Enable location access for active reminders.';

  @override
  String get mapInvalidResponseError =>
      'OpenStreetMap returned an invalid response. Try again later.';

  @override
  String get mapConnectivityError =>
      'Could not reach OpenStreetMap. Check your internet connection and allow Loc through any VPN, firewall, or data-saving app.';

  @override
  String mapHttpStatusError(int statusCode) {
    return 'Map service returned $statusCode. Try again later.';
  }
}
