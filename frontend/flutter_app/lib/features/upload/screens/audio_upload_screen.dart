import 'package:material_ui/material_ui.dart';

import '../../song_details/widgets/music_player.dart';

class AudioUploadScreen extends StatelessWidget {
  const AudioUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Local audio player')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Play audio from your device',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an MP3, WAV, M4A, or AAC file. Audio plays locally '
                    'and is not uploaded to the backend.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const MusicPlayer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
