import 'package:material_ui/material_ui.dart';

import '../models/song.dart';

class SongResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongResultTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.music_note),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(song.artist),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
