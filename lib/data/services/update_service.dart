import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loc/app/app_metadata.dart';

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppUpdate {
  const AppUpdate({required this.version, required this.downloadUri});

  final String version;
  final Uri downloadUri;
}

class UpdateService {
  UpdateService({http.Client? client, AppMetadata? appMetadata})
    : _client = client ?? http.Client(),
      _appMetadata = appMetadata ?? AppMetadata.current;

  final http.Client _client;
  final AppMetadata _appMetadata;

  Future<AppUpdate?> check() async {
    try {
      final response = await _client
          .get(
            Uri.https(
              'api.github.com',
              '/repos/AbdeltwabMF/loc/releases/latest',
            ),
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': _appMetadata.androidUserAgent,
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw UpdateException(
          'GitHub returned ${response.statusCode}. Try again later.',
        );
      }
      final release = jsonDecode(utf8.decode(response.bodyBytes));
      if (release is! Map<String, dynamic>) {
        throw const FormatException('Expected a release object');
      }
      final tag = release['tag_name'];
      final releaseUrl = release['html_url'];
      if (tag is! String || releaseUrl is! String) {
        throw const FormatException('Missing release fields');
      }
      final version = tag.startsWith('v') ? tag.substring(1) : tag;
      if (_compareVersions(version, _appMetadata.version) <= 0) return null;

      final assets = release['assets'];
      String? downloadUrl;
      if (assets is List<dynamic>) {
        for (final asset in assets.whereType<Map<String, dynamic>>()) {
          final name = asset['name'];
          final url = asset['browser_download_url'];
          if (name is String &&
              name.toLowerCase().endsWith('.apk') &&
              url is String) {
            downloadUrl = url;
            break;
          }
        }
      }
      return AppUpdate(
        version: version,
        downloadUri: Uri.parse(downloadUrl ?? releaseUrl),
      );
    } on UpdateException {
      rethrow;
    } on TimeoutException {
      throw const UpdateException('The update check timed out. Try again.');
    } on http.ClientException {
      throw const UpdateException(
        'Could not reach GitHub. Check your internet connection.',
      );
    } on FormatException {
      throw const UpdateException(
        'GitHub returned an invalid release. Try again later.',
      );
    }
  }

  int _compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftValue = index < leftParts.length ? leftParts[index] : 0;
      final rightValue = index < rightParts.length ? rightParts[index] : 0;
      if (leftValue != rightValue) return leftValue.compareTo(rightValue);
    }
    return 0;
  }

  List<int> _versionParts(String value) => value
      .split('-')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList(growable: false);

  void dispose() => _client.close();
}
