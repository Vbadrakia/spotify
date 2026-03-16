import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/track_model.dart';
import '../../repositories/track_repository.dart';

// Events
abstract class TrackEvent extends Equatable {
  const TrackEvent();
  @override
  List<Object?> get props => [];
}

class LoadTracks extends TrackEvent {}

class LoadMoreTracks extends TrackEvent {}

class SearchTracks extends TrackEvent {
  final String query;
  SearchTracks(this.query);
  @override
  List<Object?> get props => [query];
}

class UploadTrack extends TrackEvent {
  final String title;
  final String artist;
  final String? album;
  final String audioFilePath;
  final String? artworkFilePath;
  final String? lyrics;

  UploadTrack({
    required this.title,
    required this.artist,
    this.album,
    required this.audioFilePath,
    this.artworkFilePath,
    this.lyrics,
  });

  @override
  List<Object?> get props => [title, artist, album, audioFilePath, artworkFilePath, lyrics];
}

class DeleteTrack extends TrackEvent {
  final String trackId;
  DeleteTrack(this.trackId);
  @override
  List<Object?> get props => [trackId];
}

class LoadFavorites extends TrackEvent {}

class ToggleFavorite extends TrackEvent {
  final Track track;
  ToggleFavorite(this.track);
  @override
  List<Object?> get props => [track];
}

class LoadRecentlyPlayed extends TrackEvent {}

class LoadPopularTracks extends TrackEvent {}

class LoadLyrics extends TrackEvent {
  final String trackId;
  LoadLyrics(this.trackId);
  @override
  List<Object?> get props => [trackId];
}

// States
abstract class TrackState extends Equatable {
  const TrackState();
  @override
  List<Object?> get props => [];
}

class TrackInitial extends TrackState {
  const TrackInitial();
}

class TrackLoading extends TrackState {
  const TrackLoading();
}

class TrackLoaded extends TrackState {
  final List<Track> tracks;
  final List<Track> favorites;
  final List<Track> recentlyPlayed;
  final List<Track> popular;
  final String? currentLyrics;
  final bool hasMore;
  final int currentPage;

  TrackLoaded({
    required this.tracks,
    this.favorites = const [],
    this.recentlyPlayed = const [],
    this.popular = const [],
    this.currentLyrics,
    this.hasMore = true,
    this.currentPage = 1,
  });

  TrackLoaded copyWith({
    List<Track>? tracks,
    List<Track>? favorites,
    List<Track>? recentlyPlayed,
    List<Track>? popular,
    String? currentLyrics,
    bool? hasMore,
    int? currentPage,
  }) {
    return TrackLoaded(
      tracks: tracks ?? this.tracks,
      favorites: favorites ?? this.favorites,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      popular: popular ?? this.popular,
      currentLyrics: currentLyrics ?? this.currentLyrics,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [tracks, favorites, recentlyPlayed, popular, currentLyrics, hasMore, currentPage];
}

class TrackSearching extends TrackState {
  const TrackSearching();
}

class TrackSearchResults extends TrackState {
  final List<Track> results;
  final String query;
  const TrackSearchResults({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class TrackError extends TrackState {
  final String message;
  const TrackError(this.message);
  @override
  List<Object?> get props => [message];
}

class TrackUploading extends TrackState {
  const TrackUploading();
}

class TrackUploadSuccess extends TrackState {
  final Track track;
  const TrackUploadSuccess(this.track);
  @override
  List<Object?> get props => [track];
}

class LyricsLoading extends TrackState {
  const LyricsLoading();
}

class LyricsLoaded extends TrackState {
  final String lyrics;
  const LyricsLoaded(this.lyrics);
  @override
  List<Object?> get props => [lyrics];
}

// BLoC
class TrackBloc extends Bloc<TrackEvent, TrackState> {
  final TrackRepository _trackRepository;

  TrackBloc(this._trackRepository) : super(const TrackInitial()) {
    on<LoadTracks>(_onLoadTracks);
    on<LoadMoreTracks>(_onLoadMoreTracks);
    on<SearchTracks>(_onSearchTracks);
    on<UploadTrack>(_onUploadTrack);
    on<DeleteTrack>(_onDeleteTrack);
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadRecentlyPlayed>(_onLoadRecentlyPlayed);
    on<LoadPopularTracks>(_onLoadPopularTracks);
    on<LoadLyrics>(_onLoadLyrics);
  }

  Future<void> _onLoadTracks(LoadTracks event, Emitter<TrackState> emit) async {
    emit(const TrackLoading());
    try {
      final tracks = await _trackRepository.getTracks(page: 1);
      emit(TrackLoaded(tracks: tracks, hasMore: tracks.length >= 20));
    } catch (e) {
      emit(TrackError(e.toString()));
    }
  }

  Future<void> _onLoadMoreTracks(LoadMoreTracks event, Emitter<TrackState> emit) async {
    final currentState = state;
    if (currentState is TrackLoaded && currentState.hasMore) {
      try {
        final nextPage = currentState.currentPage + 1;
        final newTracks = await _trackRepository.getTracks(page: nextPage);
        emit(currentState.copyWith(
          tracks: [...currentState.tracks, ...newTracks],
          currentPage: nextPage,
          hasMore: newTracks.length >= 20,
        ));
      } catch (e) {
        emit(TrackError(e.toString()));
      }
    }
  }

  Future<void> _onSearchTracks(SearchTracks event, Emitter<TrackState> emit) async {
    if (event.query.isEmpty) {
      add(LoadTracks());
      return;
    }
    emit(const TrackSearching());
    try {
      final results = await _trackRepository.searchTracks(event.query);
      emit(TrackSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(TrackError(e.toString()));
    }
  }

  Future<void> _onUploadTrack(UploadTrack event, Emitter<TrackState> emit) async {
    emit(const TrackUploading());
    try {
      final track = await _trackRepository.uploadTrack(
        title: event.title,
        artist: event.artist,
        album: event.album,
        audioFilePath: event.audioFilePath,
        artworkFilePath: event.artworkFilePath,
        lyrics: event.lyrics,
      );
      emit(TrackUploadSuccess(track));
    } catch (e) {
      emit(TrackError(e.toString()));
    }
  }

  Future<void> _onDeleteTrack(DeleteTrack event, Emitter<TrackState> emit) async {
    try {
      await _trackRepository.deleteTrack(event.trackId);
      final currentState = state;
      if (currentState is TrackLoaded) {
        emit(currentState.copyWith(
          tracks: currentState.tracks.where((t) => t.id != event.trackId).toList(),
        ));
      }
    } catch (e) {
      emit(TrackError(e.toString()));
    }
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<TrackState> emit) async {
    final currentState = state;
    try {
      final favorites = await _trackRepository.getFavorites();
      if (currentState is TrackLoaded) {
        emit(currentState.copyWith(favorites: favorites));
      } else {
        emit(TrackLoaded(tracks: const [], favorites: favorites));
      }
    } catch (e) {
      emit(TrackError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<TrackState> emit) async {
    final currentState = state;
    if (currentState is TrackLoaded) {
      try {
        final isFavorite = currentState.favorites.any((t) => t.id == event.track.id);
        if (isFavorite) {
          await _trackRepository.removeFromFavorites(event.track.id);
        } else {
          await _trackRepository.addToFavorites(event.track.id);
        }
        final favorites = await _trackRepository.getFavorites();
        emit(currentState.copyWith(favorites: favorites));
      } catch (e) {
        emit(TrackError(e.toString()));
      }
    }
  }

  Future<void> _onLoadRecentlyPlayed(LoadRecentlyPlayed event, Emitter<TrackState> emit) async {
    final currentState = state;
    try {
      final recentlyPlayed = await _trackRepository.getRecentlyPlayed();
      if (currentState is TrackLoaded) {
        emit(currentState.copyWith(recentlyPlayed: recentlyPlayed));
      } else {
        emit(TrackLoaded(tracks: const [], recentlyPlayed: recentlyPlayed));
      }
    } catch (e) {
      // Silently fail for recently played
    }
  }

  Future<void> _onLoadPopularTracks(LoadPopularTracks event, Emitter<TrackState> emit) async {
    final currentState = state;
    try {
      final popular = await _trackRepository.getPopularTracks();
      if (currentState is TrackLoaded) {
        emit(currentState.copyWith(popular: popular));
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _onLoadLyrics(LoadLyrics event, Emitter<TrackState> emit) async {
    final currentState = state;
    emit(const LyricsLoading());
    try {
      final lyrics = await _trackRepository.getLyrics(event.trackId);
      if (lyrics != null && lyrics.isNotEmpty) {
        emit(LyricsLoaded(lyrics));
      } else {
        emit(const LyricsLoaded('No lyrics available for this track.'));
      }
      // Restore previous state
      if (currentState is TrackLoaded) {
        emit(currentState.copyWith(currentLyrics: lyrics));
      }
    } catch (e) {
      emit(TrackError('Could not load lyrics: $e'));
      if (currentState is TrackLoaded) {
        emit(currentState);
      }
    }
  }
}
