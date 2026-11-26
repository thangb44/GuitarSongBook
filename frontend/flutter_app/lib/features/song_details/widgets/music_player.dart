import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/audio/audio_playback_controller.dart';
import '../../search/models/song.dart';
import 'playback_controls.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key, this.song});

  final Song? song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(audioPlaybackControllerProvider);
    final controller = ref.read(audioPlaybackControllerProvider.notifier);
    final track = playback.track;
    final title = track?.songTitle ?? song?.title ?? track?.fileName;
    final artist = track?.artist ?? song?.artist;
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primaryContainer, colors.surface],
                    ),
                  ),
                  child: Icon(
                    Icons.album_outlined,
                    size: 40,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'No audio selected',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (artist != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        track?.fileName ??
                            'Choose an MP3, WAV, M4A, or AAC file.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: playback.isLoading
                  ? null
                  : () {
                      unawaited(_selectAudioFile(context, ref, controller));
                    },
              icon: playback.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open_outlined),
              label: Text(
                playback.track == null
                    ? 'Choose audio file'
                    : 'Choose another file',
              ),
            ),
            if (playback.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                playback.errorMessage!,
                key: const Key('audio-playback-error'),
                style: TextStyle(color: colors.error),
              ),
            ],
            const SizedBox(height: 12),
            const PlaybackControls(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAudioFile(
    BuildContext context,
    WidgetRef ref,
    AudioPlaybackController controller,
  ) async {
    await controller.selectAudioFile(
      songTitle: song?.title,
      artist: song?.artist,
    );

    if (!context.mounted) return;
    final errorMessage = ref.read(audioPlaybackControllerProvider).errorMessage;
    if (errorMessage == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unable to use this audio file'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
