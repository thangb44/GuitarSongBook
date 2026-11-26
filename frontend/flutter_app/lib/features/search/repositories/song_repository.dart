import '../models/song.dart';

abstract class SongRepository {
  Future<List<Song>> searchSongs(String query);

  Future<List<Song>> getPopularSongs();
}
