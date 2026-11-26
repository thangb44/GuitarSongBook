import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/api_error_message.dart';
import '../../../navigation/app_route_paths.dart';
import '../models/song.dart';
import '../providers/song_search_provider.dart';
import '../widgets/song_result_tile.dart';

class SongSearchScreen extends ConsumerStatefulWidget {
  const SongSearchScreen({super.key});

  @override
  ConsumerState<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends ConsumerState<SongSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _searchText = '';
  String _activeQuery = '';
  bool _isDebouncing = false;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    setState(() {
      _searchText = value;
      if (query.length < 2) {
        _activeQuery = '';
        _isDebouncing = false;
      } else {
        _isDebouncing = query != _activeQuery;
      }
    });

    if (query.length < 2 || query == _activeQuery) {
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _activeQuery = query;
        _isDebouncing = false;
      });
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _searchText = '';
      _activeQuery = '';
      _isDebouncing = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(songSearchProvider(_activeQuery));
    final query = _searchText.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guitar Songbook',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Local audio player',
            onPressed: () {
              context.pushNamed(AppRouteNames.audioUpload);
            },
            icon: const Icon(Icons.audio_file_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your next song',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search MusicBrainz by song title or artist.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search songs or artists',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              key: const Key('clear-search'),
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildSearchResults(
                      context,
                      query: query,
                      searchAsync: searchAsync,
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

  Widget _buildSearchResults(
    BuildContext context, {
    required String query,
    required AsyncValue<List<Song>> searchAsync,
  }) {
    if (query.isEmpty) {
      return const _SearchMessage(
        icon: Icons.library_music_outlined,
        message: 'Search for a song or artist to get started.',
      );
    }

    if (query.length < 2) {
      return const _SearchMessage(
        icon: Icons.search,
        message: 'Enter at least 2 characters to search.',
      );
    }

    if (_isDebouncing) {
      return const Center(
        child: SizedBox(width: 220, child: LinearProgressIndicator()),
      );
    }

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _SearchMessage(
        icon: Icons.cloud_off_outlined,
        message: apiErrorMessage(error),
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(songSearchProvider(_activeQuery)),
      ),
      data: (songs) {
        if (songs.isEmpty) {
          return const _SearchMessage(
            icon: Icons.music_off_outlined,
            message: 'No songs found. Try another title or artist.',
          );
        }

        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: songs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongResultTile(
              song: song,
              onTap: () {
                context.pushNamed(AppRouteNames.songDetails, extra: song);
              },
            );
          },
        );
      },
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
