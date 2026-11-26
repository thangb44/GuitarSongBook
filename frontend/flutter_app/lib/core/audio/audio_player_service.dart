import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<double> get volumeStream => _player.volumeStream;
  Stream<PlayerException> get errorStream => _player.errorStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  PlayerState get playerState => _player.playerState;
  double get volume => _player.volume;

  Future<void> loadFile({
    required Uri uri,
    required String? path,
    required String fileName,
  }) async {
    final source = path == null
        ? AudioSource.uri(uri, tag: fileName)
        : AudioSource.file(path, tag: fileName);
    await _player.setAudioSource(source);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> clear() async {
    await _player.stop();
    await _player.clearAudioSources();
  }

  Future<void> dispose() => _player.dispose();
}
