import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/services/update_service.dart';

const _metadata = AppMetadata(version: '1.2.3', buildNumber: '12');
const _releasesUrl = 'https://github.com/AbdeltwabMF/loc/releases';

Map<String, String> _asset(
  String abi,
  String fileName, {
  String version = '2.0.0',
}) => {
  'name': 'Loc-v$version-$abi.apk',
  'browser_download_url': '$_releasesUrl/download/v$version/$fileName',
};

UpdateService _service({
  String version = '2.0.0',
  String? releaseUrl,
  List<Object> assets = const [],
  List<String>? supportedAbis,
  SupportedAbisLoader? supportedAbisLoader,
  void Function(http.Request)? onRequest,
  int statusCode = 200,
  String? responseBody,
}) {
  final client = MockClient((request) async {
    onRequest?.call(request);
    return http.Response(
      responseBody ??
          jsonEncode({
            'tag_name': 'v$version',
            'html_url': releaseUrl ?? '$_releasesUrl/tag/v$version',
            'assets': assets,
          }),
      statusCode,
    );
  });
  final service = UpdateService(
    appMetadata: _metadata,
    supportedAbisLoader:
        supportedAbisLoader ??
        (supportedAbis == null ? null : () async => supportedAbis),
    client: client,
  );
  addTearDown(service.dispose);
  return service;
}

void main() {
  test('returns a newer release and prefers its matching ABI APK', () async {
    late http.Request captured;
    final service = _service(
      version: '1.3.0',
      supportedAbis: ['arm64-v8a', 'armeabi-v7a'],
      assets: [
        _asset('arm64-v8a', 'loc-arm64.apk', version: '1.3.0'),
        _asset('universal', 'loc-universal.apk', version: '1.3.0'),
      ],
      onRequest: (request) => captured = request,
    );

    final update = await service.check();

    expect(captured.url.host, 'api.github.com');
    expect(captured.headers['User-Agent'], contains('Loc Android/1.2.3'));
    expect(update?.version, '1.3.0');
    expect(update?.downloadUri.path, endsWith('/loc-arm64.apk'));
  });

  test('returns null when the installed version is current', () async {
    final service = _service(
      version: '1.2.3',
      releaseUrl: '$_releasesUrl/latest',
    );

    expect(await service.check(), isNull);
  });

  test('falls back to the release page when no APK is attached', () async {
    final service = _service();

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/releases/tag/v2.0.0'));
  });

  test('uses a compatible secondary ABI', () async {
    final service = _service(
      supportedAbis: ['x86', 'armeabi-v7a'],
      assets: [_asset('armeabi-v7a', 'loc-arm.apk')],
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-arm.apk'));
  });

  test('selects the x86_64 APK on a matching device', () async {
    final service = _service(
      supportedAbis: ['x86_64'],
      assets: [_asset('x86_64', 'loc-x86_64.apk')],
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-x86_64.apk'));
  });

  test('falls back to the universal APK for an unknown ABI', () async {
    final service = _service(
      supportedAbis: ['riscv64'],
      assets: [
        _asset('arm64-v8a', 'loc-arm64.apk'),
        _asset('universal', 'loc-universal.apk'),
      ],
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-universal.apk'));
  });

  test('falls back to the universal APK when ABI detection fails', () async {
    final service = _service(
      supportedAbisLoader: () => throw Exception('platform unavailable'),
      assets: [_asset('universal', 'loc-universal.apk')],
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/loc-universal.apk'));
  });

  test('falls back to the release page without a compatible APK', () async {
    final service = _service(
      supportedAbis: ['arm64-v8a'],
      assets: [_asset('x86_64', 'loc-x86_64.apk')],
    );

    final update = await service.check();

    expect(update?.downloadUri.path, endsWith('/releases/tag/v2.0.0'));
  });

  test('surfaces an actionable GitHub error', () async {
    final service = _service(statusCode: 403, responseBody: 'rate limited');

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
  });
}
