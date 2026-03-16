import 'api_service.dart';
import '../../models/playlist_model.dart';

class PlaylistService {
  final ApiService _api;

  PlaylistService(this._api);

  Future<List<Playlist>> getPlaylists() async {
    final response = await _api.get('/playlists');
    final List<dynamic> playlists = response.data['playlists'] ?? response.data;
    return playlists.map((p) => Playlist.fromJson(p)).toList();
  }

  Future<Playlist> getPlaylist(String id) async {
    final response = await _api.get('/playlists/$id');
    return Playlist.fromJson(response.data['playlist'] ?? response.data);
  }

  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  }) async {
    final response = await _api.post('/playlists', data: {
      'name': name,
      if (description != null) 'description': description,
    });
    return Playlist.fromJson(response.data['playlist'] ?? response.data);
  }

  Future<Playlist> updatePlaylist({
    required String id,
    String? name,
    String? description,
    String? artwork,
  }) async {
    final response = await _api.put('/playlists/$id', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (artwork != null) 'artwork': artwork,
    });
    return Playlist.fromJson(response.data['playlist'] ?? response.data);
  }

  Future<void> deletePlaylist(String id) async {
    await _api.delete('/playlists/$id');
  }

  Future<Playlist> addTrackToPlaylist(String playlistId, String trackId) async {
    final response = await _api.post('/playlists/$playlistId/tracks', data: {
      'trackId': trackId,
    });
    return Playlist.fromJson(response.data['playlist'] ?? response.data);
  }

  Future<Playlist> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final response = await _api.delete('/playlists/$playlistId/tracks/$trackId');
    return Playlist.fromJson(response.data['playlist'] ?? response.data);
  }
}
