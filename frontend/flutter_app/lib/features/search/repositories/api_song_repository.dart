import '../../../core/api/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/song.dart';
import 'song_repository.dart';

class ApiSongRepository implements SongRepository {
  final ApiClient apiClient;

  ApiSongRepository(this.apiClient);

  @override
  Future<List<Song>> searchSongs(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      return [];
    }

    final response = await apiClient.dio.get<Map<String, dynamic>>(
      AppConstants.songSearchPath,
      queryParameters: {
        'q': normalizedQuery,
        'limit': AppConstants.songSearchLimit,
      },
    );

    final results = response.data?['results'];
    if (results is! List) {
      throw const FormatException(
        'Song search response must include a results list.',
      );
    }

    return results
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Each song search result must be a JSON object.',
            );
          }

          return Song.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }
}
