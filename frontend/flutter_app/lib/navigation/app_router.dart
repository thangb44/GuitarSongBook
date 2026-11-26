import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../features/chord_sheet/screens/chord_sheet_screen.dart';
import '../features/search/models/song.dart';
import '../features/search/screens/song_search_screen.dart';
import '../features/song_details/screens/song_details_screen.dart';
import '../features/upload/screens/audio_upload_screen.dart';
import 'app_route_paths.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutePaths.search,
      builder: (context, state) => const SongSearchScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.songDetails,
      name: AppRouteNames.songDetails,
      builder: (context, state) => _buildSongRoute(
        state,
        (song) => SongDetailsScreen(song: song),
      ),
    ),
    GoRoute(
      path: AppRoutePaths.chordSheet,
      name: AppRouteNames.chordSheet,
      builder: (context, state) => _buildSongRoute(
        state,
        (song) => ChordSheetScreen(song: song),
      ),
    ),
    GoRoute(
      path: AppRoutePaths.upload,
      name: AppRouteNames.audioUpload,
      builder: (context, state) => const AudioUploadScreen(),
    ),
  ],
);

Widget _buildSongRoute(
  GoRouterState state,
  Widget Function(Song song) buildScreen,
) {
  final song = state.extra;
  if (song is Song) return buildScreen(song);

  return Scaffold(
    appBar: AppBar(title: const Text('Song unavailable')),
    body: const Center(
      child: Text('Return to search and select a song to continue.'),
    ),
  );
}
