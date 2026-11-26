import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/song_search_provider.dart';
import '../widgets/song_result_tile.dart';

import 'dart:async';

class SongSearchScreen extends ConsumerStatefulWidget {
  const SongSearchScreen({super.key});

  @override
  ConsumerState<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends ConsumerState<SongSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _searchQuery = value.trim();
      });
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  void _onSongSelected(String title) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Selected: $title')));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guitar Songbook',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find your next song',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Search for songs and discover their guitar chords.',
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search songs or artists...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    _searchQuery.isEmpty ? 'Popular Songs' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: songsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),

                      error: (error, stackTrace) =>
                          Center(child: Text('Something went wrong: $error')),

                      data: (songs) {
                        if (songs.isEmpty) {
                          return const Center(child: Text('No songs found.'));
                        }

                        return ListView.separated(
                          itemCount: songs.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final song = songs[index];

                            return SongResultTile(
                              song: song,
                              onTap: () => _onSongSelected(song.title),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
