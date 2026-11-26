import '../models/song.dart';
import 'song_repository.dart';

class MockSongRepository implements SongRepository {
  final List<Song> _songs = const [
    Song(
      id: '1',
      title: 'Amazing Grace',
      artist: 'Traditional',
      album: 'Christian Hymns',
    ),
    Song(id: '2', title: 'Perfect', artist: 'Ed Sheeran', album: 'Divide'),
    Song(id: '3', title: 'Wonderwall', artist: 'Oasis', album: 'Morning Glory'),
    Song(
      id: '4',
      title: 'Let Her Go',
      artist: 'Passenger',
      album: 'All the Little Lights',
    ),
    Song(id: '5', title: 'Photograph', artist: 'Ed Sheeran', album: 'X'),
    Song(
      id: '6',
      title: 'Hallelujah',
      artist: 'Leonard Cohen',
      album: 'Various Positions',
    ),
    Song(id: '7', title: 'Yellow', artist: 'Coldplay', album: 'Parachutes'),
    Song(id: '8', title: 'Someone Like You', artist: 'Adele', album: '21'),
  ];

  Future<List<Song>> getPopularSongs() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _songs;
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getPopularSongs();
    }

    return _songs.where((song) {
      return song.title.toLowerCase().contains(normalizedQuery) ||
          song.artist.toLowerCase().contains(normalizedQuery) ||
          (song.album?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }
}
