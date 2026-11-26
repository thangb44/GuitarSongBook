import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:guitar_songbook/features/search/models/song.dart';
import 'package:guitar_songbook/features/search/providers/song_search_provider.dart';
import 'package:guitar_songbook/features/search/repositories/song_repository.dart';
import 'package:guitar_songbook/features/search/widgets/song_result_tile.dart';
import 'package:guitar_songbook/main.dart';

void main() {
  testWidgets('debounces search and displays song details', (tester) async {
    final repository = _FakeSongRepository([
      const Song(
        id: 'recording-1',
        title: 'Perfect',
        artist: 'Ed Sheeran',
        album: '÷ (Deluxe)',
        durationMs: 263400,
        provider: 'musicbrainz',
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repository)],
        child: const GuitarSongbookApp(),
      ),
    );

    expect(
      find.text('Search for a song or artist to get started.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Perfect');
    await tester.pump(const Duration(milliseconds: 499));
    expect(repository.queries, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(repository.queries, ['Perfect']);
    expect(find.text('Perfect'), findsNWidgets(2));
    expect(find.text('Ed Sheeran  •  ÷ (Deluxe)'), findsOneWidget);
  });

  testWidgets('requires two characters and clears the query', (tester) async {
    final repository = _FakeSongRepository([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repository)],
        child: const GuitarSongbookApp(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'P');
    await tester.pump();

    expect(find.text('Enter at least 2 characters to search.'), findsOneWidget);
    expect(repository.queries, isEmpty);

    await tester.enterText(find.byType(TextField), 'Perfect');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(repository.queries, ['Perfect']);
    expect(
      find.text('No songs found. Try another title or artist.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('clear-search')));
    await tester.pump();

    expect(
      find.text('Search for a song or artist to get started.'),
      findsOneWidget,
    );
    expect(repository.queries, ['Perfect']);
  });

  testWidgets('shows an actionable message when the backend is unreachable', (
    tester,
  ) async {
    final repository = _FakeSongRepository(
      [],
      error: DioException(
        requestOptions: RequestOptions(path: '/api/v1/search'),
        type: DioExceptionType.connectionError,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repository)],
        child: const GuitarSongbookApp(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Perfect');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Check that the backend is running'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('opens song details and chord placeholder from search', (
    tester,
  ) async {
    final repository = _FakeSongRepository([
      const Song(
        id: 'recording-1',
        title: 'Perfect',
        artist: 'Ed Sheeran',
        album: '÷ (Deluxe)',
        durationMs: 263400,
        provider: 'musicbrainz',
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [songRepositoryProvider.overrideWithValue(repository)],
        child: const GuitarSongbookApp(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Perfect');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SongResultTile));
    await tester.pumpAndSettle();

    expect(find.text('Song details'), findsOneWidget);
    expect(find.text('MusicBrainz recording ID'), findsOneWidget);
    expect(find.text('4:23'), findsOneWidget);
    expect(find.text('Artwork unavailable'), findsOneWidget);
    expect(find.text('÷ (Deluxe)'), findsOneWidget);
    expect(find.text('recording-1'), findsOneWidget);

    await tester.ensureVisible(find.text('View Chords'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Chords'));
    await tester.pumpAndSettle();

    expect(find.text('Chord sheet'), findsOneWidget);
    expect(
      find.text('Chord generation is not implemented yet.'),
      findsOneWidget,
    );
    expect(find.text('Lyrics and chords will appear here.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Song details'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      find.text('Search MusicBrainz by song title or artist.'),
      findsOneWidget,
    );
  });

  testWidgets('opens the local audio player from search', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GuitarSongbookApp()));

    await tester.tap(find.byTooltip('Local audio player'));
    await tester.pumpAndSettle();

    expect(find.text('Play audio from your device'), findsOneWidget);
    expect(find.text('Choose audio file'), findsOneWidget);
    expect(find.textContaining('not uploaded to the backend'), findsOneWidget);
  });
}

class _FakeSongRepository implements SongRepository {
  _FakeSongRepository(this.songs, {this.error});

  final List<Song> songs;
  final Object? error;
  final List<String> queries = [];

  @override
  Future<List<Song>> searchSongs(String query) async {
    queries.add(query);
    if (error != null) {
      throw error!;
    }
    return songs;
  }
}
