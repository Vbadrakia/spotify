import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/playlist_model.dart';
import '../../repositories/playlist_repository.dart';

// Events
abstract class PlaylistEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPlaylists extends PlaylistEvent {}

class LoadPlaylistDetail extends PlaylistEvent {
  final String playlistId;

  LoadPlaylistDetail(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class CreatePlaylist extends PlaylistEvent {
  final String name;
  final String? description;

  CreatePlaylist({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdatePlaylist extends PlaylistEvent {
  final String playlistId;
  final String? name;
  final String? description;
  final String? artwork;

  UpdatePlaylist({
    required this.playlistId,
    this.name,
    this.description,
    this.artwork,
  });

  @override
  List<Object?> get props => [playlistId, name, description, artwork];
}

class DeletePlaylist extends PlaylistEvent {
  final String playlistId;

  DeletePlaylist(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class AddTrackToPlaylist extends PlaylistEvent {
  final String playlistId;
  final String trackId;

  AddTrackToPlaylist({required this.playlistId, required this.trackId});

  @override
  List<Object?> get props => [playlistId, trackId];
}

class RemoveTrackFromPlaylist extends PlaylistEvent {
  final String playlistId;
  final String trackId;

  RemoveTrackFromPlaylist({required this.playlistId, required this.trackId});

  @override
  List<Object?> get props => [playlistId, trackId];
}

// States
abstract class PlaylistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistsLoaded extends PlaylistState {
  final List<Playlist> playlists;

  PlaylistsLoaded(this.playlists);

  @override
  List<Object?> get props => [playlists];
}

class PlaylistDetailLoaded extends PlaylistState {
  final Playlist playlist;

  PlaylistDetailLoaded(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class PlaylistCreated extends PlaylistState {
  final Playlist playlist;

  PlaylistCreated(this.playlist);

  @override
  List<Object?> get props => [playlist];
}

class PlaylistError extends PlaylistState {
  final String message;

  PlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository _playlistRepository;

  PlaylistBloc(this._playlistRepository) : super(PlaylistInitial()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<LoadPlaylistDetail>(_onLoadPlaylistDetail);
    on<CreatePlaylist>(_onCreatePlaylist);
    on<UpdatePlaylist>(_onUpdatePlaylist);
    on<DeletePlaylist>(_onDeletePlaylist);
    on<AddTrackToPlaylist>(_onAddTrackToPlaylist);
    on<RemoveTrackFromPlaylist>(_onRemoveTrackFromPlaylist);
  }

  Future<void> _onLoadPlaylists(LoadPlaylists event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    try {
      final playlists = await _playlistRepository.getPlaylists();
      emit(PlaylistsLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onLoadPlaylistDetail(LoadPlaylistDetail event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    try {
      final playlist = await _playlistRepository.getPlaylist(event.playlistId);
      emit(PlaylistDetailLoaded(playlist));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onCreatePlaylist(CreatePlaylist event, Emitter<PlaylistState> emit) async {
    emit(PlaylistLoading());
    try {
      final playlist = await _playlistRepository.createPlaylist(
        name: event.name,
        description: event.description,
      );
      emit(PlaylistCreated(playlist));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onUpdatePlaylist(UpdatePlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await _playlistRepository.updatePlaylist(
        id: event.playlistId,
        name: event.name,
        description: event.description,
        artwork: event.artwork,
      );
      add(LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onDeletePlaylist(DeletePlaylist event, Emitter<PlaylistState> emit) async {
    try {
      await _playlistRepository.deletePlaylist(event.playlistId);
      add(LoadPlaylists());
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onAddTrackToPlaylist(AddTrackToPlaylist event, Emitter<PlaylistState> emit) async {
    try {
      final playlist = await _playlistRepository.addTrackToPlaylist(
        event.playlistId,
        event.trackId,
      );
      emit(PlaylistDetailLoaded(playlist));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onRemoveTrackFromPlaylist(RemoveTrackFromPlaylist event, Emitter<PlaylistState> emit) async {
    try {
      final playlist = await _playlistRepository.removeTrackFromPlaylist(
        event.playlistId,
        event.trackId,
      );
      emit(PlaylistDetailLoaded(playlist));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
