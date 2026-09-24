import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/services/update_service.dart';

const _metadata = AppMetadata(version: '1.2.3', buildNumber: '12');

void main() {
  test('returns a newer release and prefers its APK asset', () async {
    late http.Request captured;
    final service = UpdateService(
      appMetadata: _metadata,
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'tag_name': 'v1.3.0',
            'html_url':
                'https://github.com/AbdeltwabMF/loc/releases/tag/v1.3.0',
            'assets': [
              {
                'name': 'loc-v1.3.0.apk',
                'browser_download_url':
                    'https://github.com/AbdeltwabMF/loc/releases/download/v1.3.0/loc.apk',
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
    expect(update?.downloadUri.path, endsWith('/loc.apk'));
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
