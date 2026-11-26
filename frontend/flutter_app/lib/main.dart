import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/search/screens/song_search_screen.dart';

void main() {
  runApp(const ProviderScope(child: GuitarSongbookApp()));
}

class GuitarSongbookApp extends StatelessWidget {
  const GuitarSongbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guitar Songbook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const SongSearchScreen(),
    );
  }
}
