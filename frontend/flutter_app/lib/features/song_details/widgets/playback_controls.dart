import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/audio/audio_playback_controller.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(audioPlaybackControllerProvider);
    final controller = ref.read(audioPlaybackControllerProvider.notifier);
    final service = ref.watch(audioPlayerServiceProvider);
    final isEnabled = playback.track != null && !playback.isLoading;

    return StreamBuilder<Duration>(
      stream: service.positionStream,
      initialData: service.position,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration?>(
          stream: service.durationStream,
          initialData: service.duration,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data;
            final durationMs = duration?.inMilliseconds ?? 0;
            final maxSliderValue = durationMs > 0 ? durationMs.toDouble() : 1.0;
            final sliderValue = position.inMilliseconds
                .clamp(0, durationMs)
                .toDouble();

            return StreamBuilder<PlayerState>(
              stream: service.playerStateStream,
              initialData: service.playerState,
              builder: (context, playerStateSnapshot) {
                final isPlaying =
                    playerStateSnapshot.data?.playing ??
                    service.playerState.playing;

                return Column(
                  children: [
                    Slider(
                      value: sliderValue,
                      max: maxSliderValue,
                      onChanged: isEnabled && durationMs > 0
                          ? (value) {}
                          : null,
                      onChangeEnd: isEnabled && durationMs > 0
                          ? (value) {
                              unawaited(
                                controller.seek(
                                  Duration(milliseconds: value.round()),
                                ),
                              );
                            }
                          : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Restart',
                          onPressed: isEnabled
                              ? () => unawaited(controller.restart())
                              : null,
                          icon: const Icon(Icons.replay),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filled(
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          onPressed: isEnabled
                              ? () => unawaited(
                                  isPlaying
                                      ? controller.pause()
                                      : controller.play(),
                                )
                              : null,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.volume_down_outlined),
                        Expanded(
                          child: StreamBuilder<double>(
                            stream: service.volumeStream,
                            initialData: service.volume,
                            builder: (context, volumeSnapshot) {
                              final volume = (volumeSnapshot.data ?? 1.0)
                                  .clamp(0.0, 1.0)
                                  .toDouble();

                              return Slider(
                                value: volume,
                                onChanged: isEnabled ? (value) {} : null,
                                onChangeEnd: isEnabled
                                    ? (value) {
                                        unawaited(controller.setVolume(value));
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                        const Icon(Icons.volume_up_outlined),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '0:00';

  final minutes = duration.inSeconds ~/ 60;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
