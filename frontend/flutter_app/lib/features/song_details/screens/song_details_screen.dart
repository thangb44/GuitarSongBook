import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../navigation/app_route_paths.dart';
import '../../search/models/song.dart';
import '../widgets/music_player.dart';

class SongDetailsScreen extends StatelessWidget {
  const SongDetailsScreen({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Song details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final information = _SongInformation(song: song);
                final artwork = _ArtworkPlaceholder(title: song.title);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (constraints.maxWidth >= 700)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 4, child: artwork),
                            const SizedBox(width: 36),
                            Expanded(flex: 5, child: information),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 380,
                                ),
                                child: artwork,
                              ),
                            ),
                            const SizedBox(height: 28),
                            information,
                          ],
                        ),
                      const SizedBox(height: 24),
                      MusicPlayer(song: song),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              context.pushNamed(
                                AppRouteNames.chordSheet,
                                extra: song,
                              );
                            },
                            icon: const Icon(Icons.library_music_outlined),
                            label: const Text('View Chords'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Songbook saving is not implemented yet.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: const Text('Add to Songbook'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _shareSong(context),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share Song'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Song information provided by ${_providerName(song.provider)}.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareSong(BuildContext context) async {
    final album = song.album?.trim();
    final details = StringBuffer('${song.title} — ${song.artist}');

    if (album != null && album.isNotEmpty) {
      details.write('\nAlbum: $album');
    }

    details
      ..write('\nMusicBrainz recording ID: ${song.id}')
      ..write('\nSource: ${_providerName(song.provider)}');

    final messenger = ScaffoldMessenger.of(context);

    try {
      await SharePlus.instance.share(
        ShareParams(text: details.toString(), subject: song.title),
      );
    } on PlatformException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to open the share sheet.')),
      );
    }
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.surfaceContainerHigh],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.album_outlined,
                size: 88,
                color: colors.onPrimaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'Artwork unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongInformation extends StatelessWidget {
  const _SongInformation({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final album = song.album?.trim();
    final metadata = <({String label, String value})>[
      if (album != null && album.isNotEmpty) (label: 'Album', value: album),
      if (song.durationMs != null)
        (label: 'Duration', value: _formatDuration(song.durationMs!)),
      (label: 'MusicBrainz recording ID', value: song.id),
      (label: 'Source', value: _providerName(song.provider)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              children: [
                for (var index = 0; index < metadata.length; index++) ...[
                  if (index > 0) const Divider(height: 1),
                  _MetadataRow(
                    label: metadata[index].label,
                    value: metadata[index].value,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

String _formatDuration(int durationMs) {
  final totalSeconds = durationMs ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _providerName(String provider) {
  return provider.toLowerCase() == 'musicbrainz' ? 'MusicBrainz' : provider;
}
