import 'package:flutter_test/flutter_test.dart';
import 'package:guitar_songbook/features/search/repositories/mock_song_repository.dart';

void main() {
  test(
    'searches mock songs by title and artist without case sensitivity',
    () async {
      final repository = MockSongRepository();

      final titleResults = await repository.searchSongs('perfect');
      final artistResults = await repository.searchSongs('ED SHEERAN');

      expect(titleResults.map((song) => song.title), contains('Perfect'));
      expect(artistResults, isNotEmpty);
      expect(
        artistResults.every((song) => song.artist == 'Ed Sheeran'),
        isTrue,
      );
    },
  );
}
