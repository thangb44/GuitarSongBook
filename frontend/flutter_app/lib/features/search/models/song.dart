class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final int? durationMs;
  final String provider;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.durationMs,
    this.provider = 'unknown',
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final artist = json['artist'];
    final album = json['album'];
    final durationMs = json['duration_ms'];
    final provider = json['provider'];

    if (id is! String || id.isEmpty) {
      throw const FormatException('Song id must be a non-empty string.');
    }
    if (title is! String || title.isEmpty) {
      throw const FormatException('Song title must be a non-empty string.');
    }
    if (artist is! String || artist.isEmpty) {
      throw const FormatException('Song artist must be a non-empty string.');
    }
    if (album != null && album is! String) {
      throw const FormatException('Song album must be a string or null.');
    }
    if (durationMs != null && durationMs is! int) {
      throw const FormatException(
        'Song duration_ms must be an integer or null.',
      );
    }
    if (provider != null && provider is! String) {
      throw const FormatException('Song provider must be a string or null.');
    }

    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album as String?,
      durationMs: durationMs as int?,
      provider: provider as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration_ms': durationMs,
      'provider': provider,
    };
  }
}
