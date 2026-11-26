import 'package:material_ui/material_ui.dart';

import '../models/song.dart';

class SongResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongResultTile({super.key, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    final album = song.album?.trim();

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.music_note),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          album == null || album.isEmpty
              ? song.artist
              : '${song.artist}  •  $album',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
