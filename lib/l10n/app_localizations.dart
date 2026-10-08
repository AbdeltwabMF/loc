import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Loc'**
  String get appName;

  /// No description provided for @appIconSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Loc icon'**
  String get appIconSemanticLabel;

  /// No description provided for @newReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminderTooltip;

  /// No description provided for @linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open that link.'**
  String get linkOpenError;

  /// No description provided for @licenseGpl3.
  ///
  /// In en, this message translates to:
  /// **'Licensed under GPL-3.0'**
  String get licenseGpl3;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @moreOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptionsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @searchRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Search reminders'**
  String get searchRemindersHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get filterPinned;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterTriggered.
  ///
  /// In en, this message translates to:
  /// **'In range'**
  String get filterTriggered;

  /// No description provided for @filterPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get filterPaused;

  /// No description provided for @pinnedReminderSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinned reminder'**
  String get pinnedReminderSemanticLabel;

  /// No description provided for @alertDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m alert distance'**
  String alertDistanceMeters(int meters);

  /// No description provided for @reminderStatusTriggered.
  ///
  /// In en, this message translates to:
  /// **'In range'**
  String get reminderStatusTriggered;

  /// No description provided for @trackingEnabledSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking enabled'**
  String get trackingEnabledSemanticLabel;

  /// No description provided for @trackingPausedSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking paused'**
  String get trackingPausedSemanticLabel;

  /// No description provided for @unpinReminder.
  ///
  /// In en, this message translates to:
  /// **'Unpin reminder'**
  String get unpinReminder;

  /// No description provided for @pinReminder.
  ///
  /// In en, this message translates to:
  /// **'Pin reminder'**
  String get pinReminder;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get deleteReminder;

  /// No description provided for @deleteReminderConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get deleteReminderConfirmationTitle;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @distanceMetersAway.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away'**
  String distanceMetersAway(int meters);

  /// No description provided for @distanceKilometersAway.
  ///
  /// In en, this message translates to:
  /// **'{kilometers} km away'**
  String distanceKilometersAway(String kilometers);

  /// No description provided for @directionNorthShort.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get directionNorthShort;

  /// No description provided for @directionNorthEastShort.
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get directionNorthEastShort;

  /// No description provided for @directionEastShort.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get directionEastShort;

  /// No description provided for @directionSouthEastShort.
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get directionSouthEastShort;

  /// No description provided for @directionSouthShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get directionSouthShort;

  /// No description provided for @directionSouthWestShort.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get directionSouthWestShort;

  /// No description provided for @directionWestShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get directionWestShort;

  /// No description provided for @directionNorthWestShort.
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get directionNorthWestShort;

  /// No description provided for @destinationBearingDegrees.
  ///
  /// In en, this message translates to:
  /// **'Destination bearing {degrees} degrees'**
  String destinationBearingDegrees(int degrees);

  /// No description provided for @destinationStraightAhead.
  ///
  /// In en, this message translates to:
  /// **'Destination straight ahead'**
  String get destinationStraightAhead;

  /// No description provided for @destinationDegreesRight.
  ///
  /// In en, this message translates to:
  /// **'Destination {degrees} degrees to the right'**
  String destinationDegreesRight(int degrees);

  /// No description provided for @destinationDegreesLeft.
  ///
  /// In en, this message translates to:
  /// **'Destination {degrees} degrees to the left'**
  String destinationDegreesLeft(int degrees);

  /// No description provided for @noMatchingReminders.
  ///
  /// In en, this message translates to:
  /// **'No matching reminders'**
  String get noMatchingReminders;

  /// No description provided for @emptyRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Your next stop starts here'**
  String get emptyRemindersMessage;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @droppedPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropped pin'**
  String get droppedPinLabel;

  /// No description provided for @placeWithCoordinates.
  ///
  /// In en, this message translates to:
  /// **'{place} · {coordinates}'**
  String placeWithCoordinates(String place, String coordinates);

  /// No description provided for @trackingAccessHeading.
  ///
  /// In en, this message translates to:
  /// **'Tracking access'**
  String get trackingAccessHeading;

  /// No description provided for @arrivalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Arrival notifications'**
  String get arrivalNotifications;

  /// No description provided for @arrivalNotificationsEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify me when I arrive'**
  String get arrivalNotificationsEnabledDescription;

  /// No description provided for @allowNotificationsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to allow notifications'**
  String get allowNotificationsPrompt;

  /// No description provided for @screenOffTracking.
  ///
  /// In en, this message translates to:
  /// **'Screen-off tracking'**
  String get screenOffTracking;

  /// No description provided for @checkingLocationStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking Location status…'**
  String get checkingLocationStatus;

  /// No description provided for @screenOffTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Continue tracking when the screen is off'**
  String get screenOffTrackingDescription;

  /// No description provided for @locationServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Requires Location to be on'**
  String get locationServiceRequired;

  /// No description provided for @allowLocationAllTheTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow location all the time'**
  String get allowLocationAllTheTimeTitle;

  /// No description provided for @allowLocationAllTheTimeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap here, then open Permissions > Location, select “Allow all the time”'**
  String get allowLocationAllTheTimeInstructions;

  /// No description provided for @batteryOptimizationOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization is on'**
  String get batteryOptimizationOnTitle;

  /// No description provided for @disableBatteryRestrictionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn off battery restrictions for reliable screen-off tracking'**
  String get disableBatteryRestrictionsDescription;

  /// No description provided for @appearanceHeading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceHeading;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @fontGoogleSans.
  ///
  /// In en, this message translates to:
  /// **'Google Sans'**
  String get fontGoogleSans;

  /// No description provided for @fontBalooBhaijaan2.
  ///
  /// In en, this message translates to:
  /// **'Baloo Bhaijaan 2'**
  String get fontBalooBhaijaan2;

  /// No description provided for @useSystemFont.
  ///
  /// In en, this message translates to:
  /// **'Use system font'**
  String get useSystemFont;

  /// No description provided for @systemFontDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the device\'s default font'**
  String get systemFontDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @newReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminderTitle;

  /// No description provided for @editReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminderTitle;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @alertLabel.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alertLabel;

  /// No description provided for @notifyWithinLabel.
  ///
  /// In en, this message translates to:
  /// **'Notify me when I’m within'**
  String get notifyWithinLabel;

  /// No description provided for @alertStyleSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get alertStyleSound;

  /// No description provided for @alertStyleVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get alertStyleVibrate;

  /// No description provided for @alertStyleAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alertStyleAlarm;

  /// No description provided for @alertStyleSoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Plays a notification sound once'**
  String get alertStyleSoundDescription;

  /// No description provided for @alertStyleVibrateDescription.
  ///
  /// In en, this message translates to:
  /// **'Vibrates without playing a sound'**
  String get alertStyleVibrateDescription;

  /// No description provided for @alertStyleAlarmDescription.
  ///
  /// In en, this message translates to:
  /// **'Repeats using your alarm volume until dismissed'**
  String get alertStyleAlarmDescription;

  /// No description provided for @retrievingLocationAddress.
  ///
  /// In en, this message translates to:
  /// **'Retrieving location address…'**
  String get retrievingLocationAddress;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingLabel;

  /// No description provided for @createReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Create reminder'**
  String get createReminderAction;

  /// No description provided for @saveChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesAction;

  /// No description provided for @otherMapAction.
  ///
  /// In en, this message translates to:
  /// **'Other map'**
  String get otherMapAction;

  /// No description provided for @hideCoordinatesAction.
  ///
  /// In en, this message translates to:
  /// **'Hide coords'**
  String get hideCoordinatesAction;

  /// No description provided for @coordinatesShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Coords'**
  String get coordinatesShortLabel;

  /// No description provided for @reminderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder name'**
  String get reminderNameLabel;

  /// No description provided for @reminderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Central station'**
  String get reminderNameHint;

  /// No description provided for @clearReminderNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear reminder name'**
  String get clearReminderNameTooltip;

  /// No description provided for @reminderNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a reminder name'**
  String get reminderNameRequiredError;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @chooseOnMapAction.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMapAction;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @coordinateRangeError.
  ///
  /// In en, this message translates to:
  /// **'{minimum} to {maximum}'**
  String coordinateRangeError(String minimum, String maximum);

  /// No description provided for @distanceMetersShort.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceMetersShort(int meters);

  /// No description provided for @distanceKilometersShort.
  ///
  /// In en, this message translates to:
  /// **'{kilometers} km'**
  String distanceKilometersShort(String kilometers);

  /// No description provided for @distanceMetersSemantic.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meter} other{{count} meters}}'**
  String distanceMetersSemantic(int count);

  /// No description provided for @distanceKilometersSemantic.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 kilometer} other{{count} kilometers}}'**
  String distanceKilometersSemantic(num count);

  /// No description provided for @chooseInAnotherMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose in another map'**
  String get chooseInAnotherMapTitle;

  /// No description provided for @externalMapStepChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose the destination'**
  String get externalMapStepChooseDestination;

  /// No description provided for @externalMapStepTapShare.
  ///
  /// In en, this message translates to:
  /// **'Tap Share'**
  String get externalMapStepTapShare;

  /// No description provided for @externalMapStepSelectLoc.
  ///
  /// In en, this message translates to:
  /// **'Select Loc'**
  String get externalMapStepSelectLoc;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @openMapAction.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMapAction;

  /// No description provided for @noCompatibleMapAppError.
  ///
  /// In en, this message translates to:
  /// **'No compatible map app is installed'**
  String get noCompatibleMapAppError;

  /// No description provided for @destinationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Choose a destination or enter valid coordinates'**
  String get destinationRequiredError;

  /// No description provided for @reminderNotSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder was not saved'**
  String get reminderNotSavedTitle;

  /// No description provided for @reminderNotSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your entries are still here. Check your connection and try again.'**
  String get reminderNotSavedMessage;

  /// No description provided for @keepEditingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditingAction;

  /// No description provided for @chooseDestinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get chooseDestinationTitle;

  /// No description provided for @mapPickerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Pan and zoom the map under the pin'**
  String get mapPickerInstructions;

  /// No description provided for @mapTilesUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Map tiles are unavailable. You can still choose a location.'**
  String get mapTilesUnavailableMessage;

  /// No description provided for @openStreetMapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get openStreetMapAttribution;

  /// No description provided for @myLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocationTooltip;

  /// No description provided for @findingAddress.
  ///
  /// In en, this message translates to:
  /// **'Finding address…'**
  String get findingAddress;

  /// No description provided for @useThisLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get useThisLocationAction;

  /// No description provided for @allowLocationAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get allowLocationAccessTitle;

  /// No description provided for @mapLocationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Loc needs your permission to center the map where you are.'**
  String get mapLocationPermissionMessage;

  /// No description provided for @allowAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowAction;

  /// No description provided for @enableLocationInAndroidSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable location permission for Loc in Android settings.'**
  String get enableLocationInAndroidSettingsMessage;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsAction;

  /// No description provided for @notNowAction.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowAction;

  /// No description provided for @locationUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Please try again.'**
  String get locationUnknownError;

  /// No description provided for @permissionSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up permissions'**
  String get permissionSetupTitle;

  /// No description provided for @locationAccessNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore access'**
  String get locationAccessNeededTitle;

  /// No description provided for @permissionSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Loc needs the following permissions'**
  String get permissionSetupDescription;

  /// No description provided for @locationRecoveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Required permissions or device settings are disabled'**
  String get locationRecoveryDescription;

  /// No description provided for @requiredPermissionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredPermissionsHeading;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To detect when you arrive at your destination'**
  String get locationPermissionDescription;

  /// No description provided for @turnOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOnAction;

  /// No description provided for @optionalPermissionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalPermissionsHeading;

  /// No description provided for @notificationsPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPermissionTitle;

  /// No description provided for @notificationsPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To notify you when you arrive'**
  String get notificationsPermissionDescription;

  /// No description provided for @backgroundLocationSettingsInstruction.
  ///
  /// In en, this message translates to:
  /// **'In Permissions > Location, select “Allow all the time”'**
  String get backgroundLocationSettingsInstruction;

  /// No description provided for @screenOffTrackingPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To keep reminders active when your screen is off'**
  String get screenOffTrackingPermissionDescription;

  /// No description provided for @batteryAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery access'**
  String get batteryAccessTitle;

  /// No description provided for @batteryAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'To keep active reminders running reliably'**
  String get batteryAccessDescription;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @resumeRemindersAction.
  ///
  /// In en, this message translates to:
  /// **'Resume reminders'**
  String get resumeRemindersAction;

  /// No description provided for @optionalPermissionsSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'You can change optional permissions later in Settings'**
  String get optionalPermissionsSettingsNote;

  /// No description provided for @arrivalAlarmsChannelName.
  ///
  /// In en, this message translates to:
  /// **'Arrival alarms'**
  String get arrivalAlarmsChannelName;

  /// No description provided for @arrivalAlarmsChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Repeating alarms for destinations that must wake you.'**
  String get arrivalAlarmsChannelDescription;

  /// No description provided for @arrivalVibrationsChannelName.
  ///
  /// In en, this message translates to:
  /// **'Arrival vibrations'**
  String get arrivalVibrationsChannelName;

  /// No description provided for @arrivalVibrationsChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Silent vibration alerts when an active destination is reached.'**
  String get arrivalVibrationsChannelDescription;

  /// No description provided for @arrivalRemindersChannelName.
  ///
  /// In en, this message translates to:
  /// **'Arrival reminders'**
  String get arrivalRemindersChannelName;

  /// No description provided for @arrivalRemindersChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Brief alerts when an active destination is reached.'**
  String get arrivalRemindersChannelDescription;

  /// No description provided for @backgroundTrackingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Loc is watching your route'**
  String get backgroundTrackingNotificationTitle;

  /// No description provided for @backgroundTrackingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Active arrival reminders are being checked.'**
  String get backgroundTrackingNotificationBody;

  /// No description provided for @arrivalNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'You have arrived'**
  String get arrivalNotificationTitle;

  /// No description provided for @locationAccessBlockedError.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked. Enable it in Android settings.'**
  String get locationAccessBlockedError;

  /// No description provided for @locationAccessNotGrantedError.
  ///
  /// In en, this message translates to:
  /// **'Location access was not granted.'**
  String get locationAccessNotGrantedError;

  /// No description provided for @deviceLocationDisabledError.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location to track reminders.'**
  String get deviceLocationDisabledError;

  /// No description provided for @backgroundLocationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Allow location all the time so reminders work while the screen is off.'**
  String get backgroundLocationRequiredError;

  /// No description provided for @activeRemindersLocationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Location access is required for active reminders.'**
  String get activeRemindersLocationRequiredError;

  /// No description provided for @enableActiveRemindersLocationError.
  ///
  /// In en, this message translates to:
  /// **'Enable location access for active reminders.'**
  String get enableActiveRemindersLocationError;

  /// No description provided for @mapInvalidResponseError.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap returned an invalid response. Try again later.'**
  String get mapInvalidResponseError;

  /// No description provided for @mapConnectivityError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach OpenStreetMap. Check your internet connection and allow Loc through any VPN, firewall, or data-saving app.'**
  String get mapConnectivityError;

  /// No description provided for @mapHttpStatusError.
  ///
  /// In en, this message translates to:
  /// **'Map service returned {statusCode}. Try again later.'**
  String mapHttpStatusError(int statusCode);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
