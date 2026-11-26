import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../models/song.dart';
import '../repositories/song_repository.dart';
import '../repositories/api_song_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return ApiSongRepository(ref.watch(apiClientProvider));
});

final songSearchProvider = FutureProvider.family<List<Song>, String>((
  ref,
  query,
) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.length < 2) return [];

  final repository = ref.watch(songRepositoryProvider);
  return repository.searchSongs(normalizedQuery);
}, retry: (_, _) => null);
