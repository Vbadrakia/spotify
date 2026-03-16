import '../services/playlist_service.dart';
import '../../models/playlist_model.dart';

class PlaylistRepository {
  final PlaylistService _playlistService;

  PlaylistRepository(this._playlistService);

  Future<List<Playlist>> getPlaylists() {
    return _playlistService.getPlaylists();
  }

  Future<Playlist> getPlaylist(String id) {
    return _playlistService.getPlaylist(id);
  }

  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  }) {
    return _playlistService.createPlaylist(
      name: name,
      description: description,
    );
  }

  Future<Playlist> updatePlaylist({
    required String id,
    String? name,
    String? description,
    String? artwork,
  }) {
    return _playlistService.updatePlaylist(
      id: id,
      name: name,
      description: description,
      artwork: artwork,
    );
  }

  Future<void> deletePlaylist(String id) {
    return _playlistService.deletePlaylist(id);
  }

  Future<Playlist> addTrackToPlaylist(String playlistId, String trackId) {
    return _playlistService.addTrackToPlaylist(playlistId, trackId);
  }

  Future<Playlist> removeTrackFromPlaylist(String playlistId, String trackId) {
    return _playlistService.removeTrackFromPlaylist(playlistId, trackId);
  }
}
