import 'package:package_info_plus/package_info_plus.dart';

class AppMetadata {
  const AppMetadata({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  static late final AppMetadata current;

  static Future<void> initialize() async {
    final info = await PackageInfo.fromPlatform();
    current = AppMetadata(version: info.version, buildNumber: info.buildNumber);
  }

  String get displayVersion => '$version ($buildNumber)';
  String get mapUserAgent => 'Loc/$version (+https://loc.abdeltwab.xyz)';
  String get androidUserAgent =>
      'Loc Android/$version (+https://loc.abdeltwab.xyz)';
}
