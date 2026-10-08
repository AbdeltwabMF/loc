// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Loc';

  @override
  String get appIconSemanticLabel => 'أيقونة Loc';

  @override
  String get newReminderTooltip => 'تذكير جديد';

  @override
  String get linkOpenError => 'تعذّر فتح هذا الرابط.';

  @override
  String get licenseGpl3 => 'مرخّص وفقًا لرخصة GPL-3.0';

  @override
  String get remindersTitle => 'التذكيرات';

  @override
  String get moreOptionsTooltip => 'مزيد من الخيارات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sourceCode => 'الشفرة المصدرية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get searchRemindersHint => 'البحث في التذكيرات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPinned => 'المثبّتة';

  @override
  String get filterActive => 'النشطة';

  @override
  String get filterTriggered => 'ضمن النطاق';

  @override
  String get filterPaused => 'المتوقفة مؤقتًا';

  @override
  String get pinnedReminderSemanticLabel => 'تذكير مثبّت';

  @override
  String alertDistanceMeters(int meters) {
    return 'مسافة التنبيه: $meters م';
  }

  @override
  String get reminderStatusTriggered => 'ضمن النطاق';

  @override
  String get trackingEnabledSemanticLabel => 'التتبّع مفعّل';

  @override
  String get trackingPausedSemanticLabel => 'التتبّع متوقف مؤقتًا';

  @override
  String get unpinReminder => 'إلغاء تثبيت التذكير';

  @override
  String get pinReminder => 'تثبيت التذكير';

  @override
  String get deleteReminder => 'حذف التذكير';

  @override
  String get deleteReminderConfirmationTitle => 'هل تريد حذف هذا التذكير؟';

  @override
  String get actionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String distanceMetersAway(int meters) {
    return 'على بُعد $meters م';
  }

  @override
  String distanceKilometersAway(String kilometers) {
    return 'على بُعد $kilometers كم';
  }

  @override
  String get directionNorthShort => 'ش';

  @override
  String get directionNorthEastShort => 'ش ق';

  @override
  String get directionEastShort => 'ق';

  @override
  String get directionSouthEastShort => 'ج ق';

  @override
  String get directionSouthShort => 'ج';

  @override
  String get directionSouthWestShort => 'ج غ';

  @override
  String get directionWestShort => 'غ';

  @override
  String get directionNorthWestShort => 'ش غ';

  @override
  String destinationBearingDegrees(int degrees) {
    return 'اتجاه الوجهة: $degrees درجة';
  }

  @override
  String get destinationStraightAhead => 'الوجهة أمامك مباشرةً';

  @override
  String destinationDegreesRight(int degrees) {
    return 'الوجهة إلى اليمين بزاوية $degrees درجة';
  }

  @override
  String destinationDegreesLeft(int degrees) {
    return 'الوجهة إلى اليسار بزاوية $degrees درجة';
  }

  @override
  String get noMatchingReminders => 'لا توجد تذكيرات مطابقة';

  @override
  String get emptyRemindersMessage => 'محطتك التالية تبدأ من هنا';

  @override
  String get genericError => 'حدث خطأ. يُرجى المحاولة مرة أخرى.';

  @override
  String get droppedPinLabel => 'دبوس مثبّت';

  @override
  String placeWithCoordinates(String place, String coordinates) {
    return '$place · $coordinates';
  }

  @override
  String get trackingAccessHeading => 'أذونات التتبّع';

  @override
  String get arrivalNotifications => 'إشعارات الوصول';

  @override
  String get arrivalNotificationsEnabledDescription => 'أبلغني عند وصولي';

  @override
  String get allowNotificationsPrompt => 'اضغط للسماح بالإشعارات';

  @override
  String get screenOffTracking => 'التتبّع عند إيقاف الشاشة';

  @override
  String get checkingLocationStatus => 'جارٍ التحقق من حالة خدمة الموقع…';

  @override
  String get screenOffTrackingDescription => 'متابعة التتبّع عند إيقاف الشاشة';

  @override
  String get locationServiceRequired => 'يتطلب تشغيل خدمة الموقع';

  @override
  String get allowLocationAllTheTimeTitle => 'السماح بالوصول إلى الموقع دائمًا';

  @override
  String get allowLocationAllTheTimeInstructions =>
      'اضغط هنا، ثم افتح الأذونات ← الموقع، واختر «السماح طوال الوقت»';

  @override
  String get batteryOptimizationOnTitle => 'تحسين البطارية قيد التشغيل';

  @override
  String get disableBatteryRestrictionsDescription =>
      'أوقف قيود البطارية لضمان موثوقية التتبّع عند إيقاف الشاشة';

  @override
  String get appearanceHeading => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get fontGoogleSans => 'Google Sans';

  @override
  String get fontBalooBhaijaan2 => 'Baloo Bhaijaan 2';

  @override
  String get useSystemFont => 'استخدام خط النظام';

  @override
  String get systemFontDescription => 'استخدام الخط الافتراضي للجهاز';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get newReminderTitle => 'تذكير جديد';

  @override
  String get editReminderTitle => 'تعديل التذكير';

  @override
  String get destinationLabel => 'الوجهة';

  @override
  String get alertLabel => 'التنبيه';

  @override
  String get notifyWithinLabel => 'نبّهني عندما أكون على بُعد';

  @override
  String get alertStyleSound => 'صوت';

  @override
  String get alertStyleVibrate => 'اهتزاز';

  @override
  String get alertStyleAlarm => 'منبّه';

  @override
  String get alertStyleSoundDescription => 'يشغّل صوت إشعار مرة واحدة';

  @override
  String get alertStyleVibrateDescription => 'يهتز من دون تشغيل صوت';

  @override
  String get alertStyleAlarmDescription =>
      'يتكرر بمستوى صوت المنبّه حتى إيقافه';

  @override
  String get retrievingLocationAddress => 'جارٍ جلب عنوان الموقع…';

  @override
  String get savingLabel => 'جارٍ الحفظ…';

  @override
  String get createReminderAction => 'إنشاء تذكير';

  @override
  String get saveChangesAction => 'حفظ التغييرات';

  @override
  String get otherMapAction => 'خريطة أخرى';

  @override
  String get hideCoordinatesAction => 'إخفاء الإحداثيات';

  @override
  String get coordinatesShortLabel => 'الإحداثيات';

  @override
  String get reminderNameLabel => 'اسم التذكير';

  @override
  String get reminderNameHint => 'المحطة المركزية';

  @override
  String get clearReminderNameTooltip => 'مسح اسم التذكير';

  @override
  String get reminderNameRequiredError => 'أدخل اسمًا للتذكير';

  @override
  String get changeAction => 'تغيير';

  @override
  String get chooseOnMapAction => 'اختيار من الخريطة';

  @override
  String get latitudeLabel => 'خط العرض';

  @override
  String get longitudeLabel => 'خط الطول';

  @override
  String coordinateRangeError(String minimum, String maximum) {
    return 'من $minimum إلى $maximum';
  }

  @override
  String distanceMetersShort(int meters) {
    return '$meters م';
  }

  @override
  String distanceKilometersShort(String kilometers) {
    return '$kilometers كم';
  }

  @override
  String distanceMetersSemantic(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متر',
      many: '$count مترًا',
      few: '$count أمتار',
      two: 'متران',
      one: 'متر واحد',
      zero: '٠ متر',
    );
    return '$_temp0';
  }

  @override
  String distanceKilometersSemantic(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كيلومتر',
      many: '$count كيلومترًا',
      few: '$count كيلومترات',
      two: 'كيلومتران',
      one: 'كيلومتر واحد',
      zero: '٠ كيلومتر',
    );
    return '$_temp0';
  }

  @override
  String get chooseInAnotherMapTitle => 'اختر في خريطة أخرى';

  @override
  String get externalMapStepChooseDestination => 'اختر الوجهة';

  @override
  String get externalMapStepTapShare => 'اضغط على «مشاركة»';

  @override
  String get externalMapStepSelectLoc => 'اختر Loc';

  @override
  String get dontShowAgain => 'لا تعرض هذا مرة أخرى';

  @override
  String get openMapAction => 'فتح الخريطة';

  @override
  String get noCompatibleMapAppError => 'لا يوجد تطبيق خرائط متوافق مثبّت';

  @override
  String get destinationRequiredError => 'اختر وجهة أو أدخل إحداثيات صالحة';

  @override
  String get reminderNotSavedTitle => 'لم يتم حفظ التذكير';

  @override
  String get reminderNotSavedMessage =>
      'ما زالت بياناتك موجودة. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get keepEditingAction => 'متابعة التعديل';

  @override
  String get chooseDestinationTitle => 'اختيار الوجهة';

  @override
  String get mapPickerInstructions =>
      'حرّك الخريطة وكبّرها أو صغّرها تحت الدبوس';

  @override
  String get mapTilesUnavailableMessage =>
      'مربعات الخريطة غير متاحة. لا يزال بإمكانك اختيار موقع.';

  @override
  String get openStreetMapAttribution => '© مساهمو OpenStreetMap';

  @override
  String get myLocationTooltip => 'موقعي';

  @override
  String get findingAddress => 'جارٍ البحث عن العنوان…';

  @override
  String get useThisLocationAction => 'استخدام هذا الموقع';

  @override
  String get allowLocationAccessTitle => 'السماح بالوصول إلى الموقع';

  @override
  String get mapLocationPermissionMessage =>
      'يحتاج Loc إلى إذنك لتوسيط الخريطة على موقعك.';

  @override
  String get allowAction => 'سماح';

  @override
  String get enableLocationInAndroidSettingsMessage =>
      'فعّل إذن الموقع لتطبيق Loc من إعدادات Android.';

  @override
  String get openSettingsAction => 'فتح الإعدادات';

  @override
  String get notNowAction => 'ليس الآن';

  @override
  String get locationUnknownError => 'تعذّر تحديد موقعك. حاول مرة أخرى.';

  @override
  String get permissionSetupTitle => 'إعداد الأذونات';

  @override
  String get locationAccessNeededTitle => 'استعادة الوصول';

  @override
  String get permissionSetupDescription => 'يحتاج Loc إلى الأذونات التالية';

  @override
  String get locationRecoveryDescription =>
      'بعض الأذونات المطلوبة أو إعدادات الجهاز معطّلة';

  @override
  String get requiredPermissionsHeading => 'مطلوب';

  @override
  String get locationPermissionTitle => 'الموقع';

  @override
  String get locationPermissionDescription => 'لاكتشاف وصولك إلى وجهتك';

  @override
  String get turnOnAction => 'تشغيل';

  @override
  String get optionalPermissionsHeading => 'اختياري';

  @override
  String get notificationsPermissionTitle => 'الإشعارات';

  @override
  String get notificationsPermissionDescription => 'لإشعارك عند وصولك';

  @override
  String get backgroundLocationSettingsInstruction =>
      'في «الأذونات» ← «الموقع»، اختر «السماح طوال الوقت»';

  @override
  String get screenOffTrackingPermissionDescription =>
      'لإبقاء التذكيرات نشطة عند إيقاف الشاشة';

  @override
  String get batteryAccessTitle => 'الوصول إلى البطارية';

  @override
  String get batteryAccessDescription =>
      'لضمان استمرار عمل التذكيرات النشطة بموثوقية';

  @override
  String get continueAction => 'متابعة';

  @override
  String get resumeRemindersAction => 'استئناف التذكيرات';

  @override
  String get optionalPermissionsSettingsNote =>
      'يمكنك تغيير الأذونات الاختيارية لاحقًا من الإعدادات';

  @override
  String get arrivalAlarmsChannelName => 'منبّهات الوصول';

  @override
  String get arrivalAlarmsChannelDescription =>
      'منبّهات متكررة للوجهات التي تتطلب إيقاظك.';

  @override
  String get arrivalVibrationsChannelName => 'اهتزازات الوصول';

  @override
  String get arrivalVibrationsChannelDescription =>
      'تنبيهات اهتزاز صامتة عند الوصول إلى وجهة نشطة.';

  @override
  String get arrivalRemindersChannelName => 'تذكيرات الوصول';

  @override
  String get arrivalRemindersChannelDescription =>
      'تنبيهات موجزة عند الوصول إلى وجهة نشطة.';

  @override
  String get backgroundTrackingNotificationTitle => 'يتابع Loc مسارك';

  @override
  String get backgroundTrackingNotificationBody =>
      'جارٍ التحقّق من تذكيرات الوصول النشطة.';

  @override
  String get arrivalNotificationTitle => 'لقد وصلت';

  @override
  String get locationAccessBlockedError =>
      'الوصول إلى الموقع محظور. فعّله من إعدادات Android.';

  @override
  String get locationAccessNotGrantedError =>
      'لم يتم منح إذن الوصول إلى الموقع.';

  @override
  String get deviceLocationDisabledError =>
      'شغّل خدمة الموقع في الجهاز لتتبّع التذكيرات.';

  @override
  String get backgroundLocationRequiredError =>
      'اسمح بالوصول إلى الموقع طوال الوقت لكي تعمل التذكيرات عند إيقاف الشاشة.';

  @override
  String get activeRemindersLocationRequiredError =>
      'يلزم الوصول إلى الموقع للتذكيرات النشطة.';

  @override
  String get enableActiveRemindersLocationError =>
      'فعّل الوصول إلى الموقع للتذكيرات النشطة.';

  @override
  String get mapInvalidResponseError =>
      'أعاد OpenStreetMap استجابة غير صالحة. حاول مرة أخرى لاحقًا.';

  @override
  String get mapConnectivityError =>
      'تعذّر الاتصال بـ OpenStreetMap. تحقّق من اتصال الإنترنت واسمح لتطبيق Loc بالمرور عبر أي شبكة VPN أو جدار حماية أو تطبيق لتوفير البيانات.';

  @override
  String mapHttpStatusError(int statusCode) {
    return 'أعادت خدمة الخرائط الرمز $statusCode. حاول مرة أخرى لاحقًا.';
  }
}
