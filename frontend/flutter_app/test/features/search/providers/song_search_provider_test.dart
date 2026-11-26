import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guitar_songbook/features/search/models/song.dart';
import 'package:guitar_songbook/features/search/providers/song_search_provider.dart';
import 'package:guitar_songbook/features/search/repositories/song_repository.dart';

void main() {
  test('does not automatically retry a failed search', () async {
    final repository = _FailingSongRepository();
    final container = ProviderContainer(
      overrides: [songRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(songSearchProvider('Perfect').future),
      throwsA(isA<Exception>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));

    expect(repository.requestCount, 1);
  });
}

class _FailingSongRepository implements SongRepository {
  int requestCount = 0;

  @override
  Future<List<Song>> searchSongs(String query) async {
    requestCount++;
    throw Exception('Backend unavailable');
  }
}
