import 'api_service.dart';
import '../models/track_model.dart';

class TrackService {
  final ApiService _api;

  TrackService(this._api);

  Future<List<Track>> getTracks({int page = 1, int limit = 20}) async {
    final response = await _api.get('/tracks', queryParameters: {'page': page, 'limit': limit});
    final List<dynamic> tracks = response.data['tracks'] ?? response.data;
    return tracks.map((t) => Track.fromJson(t)).toList();
  }

  Future<Track> getTrack(String id) async {
    final response = await _api.get('/tracks/$id');
    return Track.fromJson(response.data['track'] ?? response.data);
  }

  Future<String?> getLyrics(String trackId) async {
    final response = await _api.get('/tracks/$trackId/lyrics');
    return response.data['lyrics'];
  }

  Future<List<Track>> searchTracks(String query) async {
    final response = await _api.get('/tracks/search', queryParameters: {'q': query});
    final List<dynamic> tracks = response.data['tracks'] ?? response.data;
    return tracks.map((t) => Track.fromJson(t)).toList();
  }

  Future<Track> uploadTrack({
    required String title,
    required String artist,
    String? album,
    required String audioFilePath,
    String? artworkFilePath,
    String? lyrics,
  }) async {
    final response = await _api.uploadFiles(
      '/tracks',
      {
        'audio': audioFilePath,
        if (artworkFilePath != null) 'artwork': artworkFilePath,
      },
      data: {
        'title': title,
        'artist': artist,
        if (album != null) 'album': album,
        if (lyrics != null) 'lyrics': lyrics,
      },
    );
    return Track.fromJson(response.data['track'] ?? response.data);
  }

  Future<void> deleteTrack(String id) async {
    await _api.delete('/tracks/$id');
  }

  Future<List<Track>> getFavorites() async {
    final response = await _api.get('/favorites');
    final List<dynamic> tracks = response.data['tracks'] ?? response.data;
    return tracks.map((t) => Track.fromJson(t)).toList();
  }

  Future<void> addToFavorites(String trackId) async {
    await _api.post('/favorites/$trackId');
  }

  Future<void> removeFromFavorites(String trackId) async {
    await _api.delete('/favorites/$trackId');
  }

  Future<List<Track>> getRecentlyPlayed() async {
    final response = await _api.get('/tracks/recent');
    final List<dynamic> tracks = response.data['tracks'] ?? response.data;
    return tracks.map((t) => Track.fromJson(t)).toList();
  }

  Future<List<Track>> getPopularTracks({int limit = 20}) async {
    final response = await _api.get('/tracks/popular', queryParameters: {'limit': limit});
    final List<dynamic> tracks = response.data['tracks'] ?? response.data;
    return tracks.map((t) => Track.fromJson(t)).toList();
  }
}
