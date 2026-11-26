import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import '../repositories/mock_song_repository.dart';
import '../repositories/song_repository.dart';

// Repository dependency
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return MockSongRepository();
});

// Search provider
final songSearchProvider = FutureProvider.family<List<Song>, String>((
  ref,
  query,
) async {
  final repository = ref.watch(songRepositoryProvider);

  if (query.trim().isEmpty) {
    return repository.getPopularSongs();
  }

  return repository.searchSongs(query);
});
