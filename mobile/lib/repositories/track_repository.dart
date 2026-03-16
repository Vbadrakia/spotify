import '../services/track_service.dart';
import '../../models/track_model.dart';

class TrackRepository {
  final TrackService _trackService;

  TrackRepository(this._trackService);

  Future<List<Track>> getTracks({int page = 1, int limit = 20}) {
    return _trackService.getTracks(page: page, limit: limit);
  }

  Future<Track> getTrack(String id) {
    return _trackService.getTrack(id);
  }

  Future<String?> getLyrics(String trackId) {
    return _trackService.getLyrics(trackId);
  }

  Future<List<Track>> searchTracks(String query) {
    return _trackService.searchTracks(query);
  }

  Future<Track> uploadTrack({
    required String title,
    required String artist,
    String? album,
    required String audioFilePath,
    String? artworkFilePath,
    String? lyrics,
  }) {
    return _trackService.uploadTrack(
      title: title,
      artist: artist,
      album: album,
      audioFilePath: audioFilePath,
      artworkFilePath: artworkFilePath,
      lyrics: lyrics,
    );
  }

  Future<void> deleteTrack(String id) {
    return _trackService.deleteTrack(id);
  }

  Future<List<Track>> getFavorites() {
    return _trackService.getFavorites();
  }

  Future<void> addToFavorites(String trackId) {
    return _trackService.addToFavorites(trackId);
  }

  Future<void> removeFromFavorites(String trackId) {
    return _trackService.removeFromFavorites(trackId);
  }

  Future<List<Track>> getRecentlyPlayed() {
    return _trackService.getRecentlyPlayed();
  }

  Future<List<Track>> getPopularTracks({int limit = 20}) {
    return _trackService.getPopularTracks(limit: limit);
  }
}
