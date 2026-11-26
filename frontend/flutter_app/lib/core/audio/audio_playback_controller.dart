import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_service.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final audioPlaybackControllerProvider =
    NotifierProvider<AudioPlaybackController, AudioPlaybackState>(
      AudioPlaybackController.new,
    );

class AudioTrack {
  const AudioTrack({
    required this.fileName,
    this.songTitle,
    this.artist,
  });

  final String fileName;
  final String? songTitle;
  final String? artist;
}

class AudioPlaybackState {
  const AudioPlaybackState({
    this.track,
    this.isLoading = false,
    this.errorMessage,
  });

  final AudioTrack? track;
  final bool isLoading;
  final String? errorMessage;

  AudioPlaybackState copyWith({
    AudioTrack? track,
    bool? isLoading,
    String? errorMessage,
    bool clearTrack = false,
    bool clearError = false,
  }) {
    return AudioPlaybackState(
      track: clearTrack ? null : track ?? this.track,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AudioPlaybackController extends Notifier<AudioPlaybackState> {
  static const _supportedExtensions = {'mp3', 'wav', 'm4a', 'aac'};

  late AudioPlayerService _service;

  @override
  AudioPlaybackState build() {
    _service = ref.watch(audioPlayerServiceProvider);
    final errorSubscription = _service.errorStream.listen(_handlePlayerError);
    ref.onDispose(() => unawaited(errorSubscription.cancel()));
    return const AudioPlaybackState();
  }

  Future<void> selectAudioFile({String? songTitle, String? artist}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Select an audio file',
        type: FileType.custom,
        allowedExtensions: _supportedExtensions.toList(),
      );

      if (files.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final file = files.first;
      final extension = file.extension?.toLowerCase();
      if (extension == null || !_supportedExtensions.contains(extension)) {
        throw const FormatException(
          'Choose an MP3, WAV, M4A, or AAC audio file.',
        );
      }

      final length = await file.length();
      if (length == 0) {
        throw const FormatException('The selected audio file is empty.');
      }
      if (file.path == null && !file.uri.hasScheme) {
        throw const FormatException('The selected file could not be opened.');
      }

      await _service.clear();
      state = AudioPlaybackState(
        track: AudioTrack(
          fileName: file.name,
          songTitle: songTitle,
          artist: artist,
        ),
        isLoading: true,
      );
      await _service.loadFile(
        uri: file.uri,
        path: file.path,
        fileName: file.name,
      );
      state = state.copyWith(isLoading: false);
    } on Exception catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(error),
      );
    }
  }

  Future<void> play() async {
    await _runPlayerAction(() async {
      if (_service.playerState.processingState == ProcessingState.completed) {
        await _service.seek(Duration.zero);
      }
      await _service.play();
    });
  }

  Future<void> pause() => _runPlayerAction(_service.pause);

  Future<void> restart() => _runPlayerAction(() async {
    await _service.seek(Duration.zero);
    await _service.play();
  });

  Future<void> seek(Duration position) => _runPlayerAction(() async {
    final duration = _service.duration;
    final boundedPosition = duration == null
        ? position
        : Duration(
            milliseconds: position.inMilliseconds
                .clamp(0, duration.inMilliseconds)
                .toInt(),
          );
    await _service.seek(boundedPosition);
  });

  Future<void> setVolume(double volume) => _runPlayerAction(
    () => _service.setVolume(volume.clamp(0.0, 1.0).toDouble()),
  );

  Future<void> _runPlayerAction(Future<void> Function() action) async {
    if (state.track == null) return;

    state = state.copyWith(clearError: true);
    try {
      await action();
    } on Exception catch (error) {
      state = state.copyWith(errorMessage: _errorMessage(error));
    }
  }

  void _handlePlayerError(PlayerException error) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: _errorMessage(error),
    );
  }

  String _errorMessage(Exception error) {
    if (error is FormatException) return error.message;
    if (error is PlayerException) {
      return 'Playback failed: ${error.message ?? 'Unsupported or invalid audio file.'}';
    }
    if (error is PlatformException) {
      return error.message ?? 'The selected audio file could not be opened.';
    }
    return 'Unable to play the selected audio file: $error';
  }
}
