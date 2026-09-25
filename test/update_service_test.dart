import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/services/update_service.dart';

const _metadata = AppMetadata(version: '1.2.3', buildNumber: '12');

void main() {
  test('returns a newer release and prefers its matching ABI APK', () async {
    late http.Request captured;
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () async => ['arm64-v8a', 'armeabi-v7a'],
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'tag_name': 'v1.3.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v1.3.0',
            'assets': [
              {
                'name': 'Loc-v1.3.0-arm64-v8a.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v1.3.0/loc-arm64.apk',
              },
              {
                'name': 'Loc-v1.3.0-universal.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v1.3.0/loc-universal.apk',
              },
            ],
          }),
          200,
        );
      }),
    );

    final update = await service.check();

    expect(captured.url.host, 'api.github.com');
    expect(captured.headers['User-Agent'], contains('Loc Android/1.2.3'));
    expect(update?.version, '1.3.0');
    expect(update?.downloadUri.path, endsWith('/loc-arm64.apk'));
    service.dispose();
  });

  test('returns null when the installed version is current', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v1.2.3',
            'html_url': 'https://github.com/AbdeltwabMF/loc/releases/latest',
            'assets': <Object>[],
          }),
          200,
        ),
      ),
    );

    expect(await service.check(), isNull);
    service.dispose();
  });

  test('falls back to the release page when no APK is attached', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': <Object>[],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/releases/tag/v2.0.0'));
    service.dispose();
  });

  test('uses a compatible secondary ABI', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () async => ['x86', 'armeabi-v7a'],
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': [
              {
                'name': 'Loc-v2.0.0-armeabi-v7a.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-arm.apk',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-arm.apk'));
    service.dispose();
  });

  test('selects the x86_64 APK on a matching device', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () async => ['x86_64'],
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': [
              {
                'name': 'Loc-v2.0.0-x86_64.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-x86_64.apk',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-x86_64.apk'));
    service.dispose();
  });

  test('falls back to the universal APK for an unknown ABI', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () async => ['riscv64'],
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': [
              {
                'name': 'Loc-v2.0.0-arm64-v8a.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-arm64.apk',
              },
              {
                'name': 'Loc-v2.0.0-universal.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-universal.apk',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-universal.apk'));
    service.dispose();
  });

  test('falls back to the universal APK when ABI detection fails', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () => throw Exception('platform unavailable'),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': [
              {
                'name': 'Loc-v2.0.0-universal.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-universal.apk',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-universal.apk'));
    service.dispose();
  });

  test('falls back to the release page without a compatible APK', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      supportedAbisLoader: () async => ['arm64-v8a'],
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'tag_name': 'v2.0.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v2.0.0',
            'assets': [
              {
                'name': 'Loc-v2.0.0-x86_64.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v2.0.0/loc-x86_64.apk',
              },
            ],
          }),
          200,
        ),
      ),
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/releases/tag/v2.0.0'));
    service.dispose();
  });

  test('surfaces an actionable GitHub error', () async {
    final service = UpdateService(
      appMetadata: _metadata,
      client: MockClient((_) async => http.Response('rate limited', 403)),
    );

    await expectLater(
      service.check(),
      throwsA(
        isA<UpdateException>().having(
          (error) => error.message,
          'message',
          contains('403'),
        ),
      ),
    );
    service.dispose();
  });
}
