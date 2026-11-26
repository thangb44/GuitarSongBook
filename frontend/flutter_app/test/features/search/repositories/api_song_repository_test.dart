import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guitar_songbook/features/search/repositories/api_song_repository.dart';
import 'package:guitar_songbook/core/api/api_client.dart';

void main() {
  test('requests the backend search endpoint and maps its results', () async {
    final adapter = _FakeHttpClientAdapter(
      ResponseBody.fromString(
        jsonEncode({
          'results': [
            {
              'id': 'recording-1',
              'title': 'Perfect',
              'artist': 'Ed Sheeran',
              'album': '÷ (Deluxe)',
              'duration_ms': 263400,
              'provider': 'musicbrainz',
            },
          ],
          'total': 1,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    final repository = ApiSongRepository(ApiClient(dio: dio));

    final songs = await repository.searchSongs('  Perfect  ');

    expect(adapter.requestOptions.path, '/api/v1/search');
    expect(adapter.requestOptions.queryParameters, {
      'q': 'Perfect',
      'limit': 10,
    });
    expect(songs, hasLength(1));
    expect(songs.single.title, 'Perfect');
    expect(songs.single.artist, 'Ed Sheeran');
    expect(songs.single.album, '÷ (Deluxe)');
    expect(songs.single.durationMs, 263400);
    expect(songs.single.provider, 'musicbrainz');

    dio.close();
  });

  test('does not request the backend for too-short queries', () async {
    final adapter = _FakeHttpClientAdapter(ResponseBody.fromString('{}', 200));
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    final repository = ApiSongRepository(ApiClient(dio: dio));

    expect(await repository.searchSongs(' P '), isEmpty);
    expect(adapter.didFetch, isFalse);

    dio.close();
  });

  test('reports an invalid response shape', () async {
    final adapter = _FakeHttpClientAdapter(
      ResponseBody.fromString(
        '{"total": 0}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    final repository = ApiSongRepository(ApiClient(dio: dio));

    await expectLater(
      repository.searchSongs('Perfect'),
      throwsA(isA<FormatException>()),
    );

    dio.close();
  });
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.responseBody);

  final ResponseBody responseBody;
  RequestOptions? _requestOptions;

  RequestOptions get requestOptions => _requestOptions!;
  bool get didFetch => _requestOptions != null;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requestOptions = options;
    return responseBody;
  }

  @override
  void close({bool force = false}) {}
}
