class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artworkUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.artworkUrl,
  });
}
