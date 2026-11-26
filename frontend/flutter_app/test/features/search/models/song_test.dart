import 'package:flutter_test/flutter_test.dart';
import 'package:guitar_songbook/features/search/models/song.dart';

void main() {
  test('maps the backend song response and serializes it', () {
    final song = Song.fromJson({
      'id': 'musicbrainz-recording-id',
      'title': 'Perfect',
      'artist': 'Ed Sheeran',
      'album': '÷ (Deluxe)',
      'duration_ms': 263400,
      'provider': 'musicbrainz',
    });

    expect(song.id, 'musicbrainz-recording-id');
    expect(song.title, 'Perfect');
    expect(song.artist, 'Ed Sheeran');
    expect(song.album, '÷ (Deluxe)');
    expect(song.durationMs, 263400);
    expect(song.provider, 'musicbrainz');
    expect(song.toJson()['duration_ms'], 263400);
  });

  test('uses optional backend field defaults', () {
    final song = Song.fromJson({
      'id': 'recording-2',
      'title': 'Untitled',
      'artist': 'Unknown Artist',
    });

    expect(song.album, isNull);
    expect(song.durationMs, isNull);
    expect(song.provider, 'unknown');
  });

  test('rejects a response without required song fields', () {
    expect(
      () => Song.fromJson({'id': 'recording-3', 'title': 'Missing artist'}),
      throwsA(isA<FormatException>()),
    );
  });
}
