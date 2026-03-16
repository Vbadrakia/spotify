import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/track_model.dart';
import '../../services/audio_player_service.dart';

// Events
abstract class PlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayTrack extends PlayerEvent {
  final Track track;
  final List<Track>? queue;

  PlayTrack(this.track, {this.queue});

  @override
  List<Object?> get props => [track, queue];
}

class PlayQueue extends PlayerEvent {
  final List<Track> tracks;
  final int startIndex;

  PlayQueue(this.tracks, {this.startIndex = 0});

  @override
  List<Object?> get props => [tracks, startIndex];
}

class TogglePlayPause extends PlayerEvent {}

class PlayNext extends PlayerEvent {}

class PlayPrevious extends PlayerEvent {}

class SeekTo extends PlayerEvent {
  final Duration position;

  SeekTo(this.position);

  @override
  List<Object?> get props => [position];
}

class SetVolume extends PlayerEvent {
  final double volume;

  SetVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ToggleShuffle extends PlayerEvent {}

class ToggleRepeat extends PlayerEvent {}

class AddToQueue extends PlayerEvent {
  final Track track;

  AddToQueue(this.track);

  @override
  List<Object?> get props => [track];
}

class RemoveFromQueue extends PlayerEvent {
  final int index;

  RemoveFromQueue(this.index);

  @override
  List<Object?> get props => [index];
}

class ClearQueue extends PlayerEvent {}

class ReorderQueue extends PlayerEvent {
  final int oldIndex;
  final int newIndex;

  ReorderQueue({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class PlayFromQueue extends PlayerEvent {
  final int index;

  PlayFromQueue(this.index);

  @override
  List<Object?> get props => [index];
}

class PlayerStateChanged extends PlayerEvent {}

// Repeat Mode Enum
enum RepeatMode { off, all, one }

// States
class PlayerState extends Equatable {
  final Track? currentTrack;
  final List<Track> queue;
  final List<Track> originalQueue; // Keep original order when shuffle
  final int currentIndex;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffle;
  final RepeatMode repeatMode;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.originalQueue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
  });

  PlayerState copyWith({
    Track? currentTrack,
    List<Track>? queue,
    List<Track>? originalQueue,
    int? currentIndex,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffle,
    RepeatMode? repeatMode,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      originalQueue: originalQueue ?? this.originalQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  @override
  List<Object?> get props => [
    currentTrack, 
    queue, 
    originalQueue,
    currentIndex, 
    isPlaying, 
    isBuffering,
    position, 
    duration, 
    volume, 
    isShuffle, 
    repeatMode
  ];
}

// BLoC
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _playerService;

  AudioPlayerService get playerService => _playerService;

  PlayerBloc(this._playerService) : super(const PlayerState()) {
    on<PlayTrack>(_onPlayTrack);
    on<PlayQueue>(_onPlayQueue);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<PlayNext>(_onPlayNext);
    on<PlayPrevious>(_onPlayPrevious);
    on<SeekTo>(_onSeekTo);
    on<SetVolume>(_onSetVolume);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleRepeat>(_onToggleRepeat);
    on<AddToQueue>(_onAddToQueue);
    on<RemoveFromQueue>(_onRemoveFromQueue);
    on<ClearQueue>(_onClearQueue);
    on<ReorderQueue>(_onReorderQueue);
    on<PlayFromQueue>(_onPlayFromQueue);
    on<PlayerStateChanged>(_onPlayerStateChanged);

    _playerService.addListener(_onPlayerStateChangedInternal);
  }

  void _onPlayerStateChangedInternal() {
    add(PlayerStateChanged());
  }

  Future<void> _onPlayTrack(PlayTrack event, Emitter<PlayerState> emit) async {
    final queue = event.queue ?? [event.track];
    await _playerService.setQueue(queue, startIndex: 0);
    await _playerService.play();
    
    emit(state.copyWith(
      currentTrack: event.track,
      queue: queue,
      originalQueue: queue,
      currentIndex: 0,
      isPlaying: true,
    ));
  }

  Future<void> _onPlayQueue(PlayQueue event, Emitter<PlayerState> emit) async {
    List<Track> queueToPlay = List.from(event.tracks);
    
    if (state.isShuffle) {
      queueToPlay.shuffle();
      // Move the startIndex track to front
      if (event.startIndex < event.tracks.length) {
        final startTrack = event.tracks[event.startIndex];
        queueToPlay.remove(startTrack);
        queueToPlay.insert(0, startTrack);
      }
    }
    
    await _playerService.setQueue(queueToPlay, startIndex: 0);
    await _playerService.play();
    
    emit(state.copyWith(
      currentTrack: queueToPlay[0],
      queue: queueToPlay,
      originalQueue: event.tracks,
      currentIndex: 0,
      isPlaying: true,
    ));
  }

  Future<void> _onTogglePlayPause(TogglePlayPause event, Emitter<PlayerState> emit) async {
    if (_playerService.isPlaying) {
      await _playerService.pause();
    } else {
      await _playerService.play();
    }
  }

  Future<void> _onPlayNext(PlayNext event, Emitter<PlayerState> emit) async {
    if (state.repeatMode == RepeatMode.one) {
      await _playerService.seek(Duration.zero);
      await _playerService.play();
      return;
    }
    
    if (state.currentIndex < state.queue.length - 1) {
      await _playerService.playNext();
    } else if (state.repeatMode == RepeatMode.all && state.queue.isNotEmpty) {
      // Loop back to start
      await _playerService.setQueue(state.queue, startIndex: 0);
      await _playerService.play();
    }
  }

  Future<void> _onPlayPrevious(PlayPrevious event, Emitter<PlayerState> emit) async {
    // If more than 3 seconds in, restart current track
    if (state.position.inSeconds > 3) {
      await _playerService.seek(Duration.zero);
      return;
    }
    
    if (state.currentIndex > 0) {
      await _playerService.playPrevious();
    } else if (state.repeatMode == RepeatMode.all && state.queue.isNotEmpty) {
      await _playerService.setQueue(state.queue, startIndex: state.queue.length - 1);
      await _playerService.play();
    }
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<PlayerState> emit) async {
    await _playerService.seek(event.position);
  }

  Future<void> _onSetVolume(SetVolume event, Emitter<PlayerState> emit) async {
    await _playerService.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onToggleShuffle(ToggleShuffle event, Emitter<PlayerState> emit) async {
    final newShuffleState = !state.isShuffle;
    
    if (newShuffleState) {
      // Shuffle the queue but keep current track at position
      final currentTrack = state.currentTrack;
      List<Track> shuffled = List.from(state.queue)..shuffle();
      
      // Move current track to front
      if (currentTrack != null) {
        shuffled.remove(currentTrack);
        shuffled.insert(0, currentTrack);
      }
      
      emit(state.copyWith(
        isShuffle: true,
        queue: shuffled,
        currentIndex: 0,
      ));
    } else {
      // Restore original order
      final currentTrack = state.currentTrack;
      final newIndex = currentTrack != null 
          ? state.originalQueue.indexOf(currentTrack) 
          : 0;
      
      emit(state.copyWith(
        isShuffle: false,
        queue: List.from(state.originalQueue),
        currentIndex: newIndex >= 0 ? newIndex : 0,
      ));
    }
  }

  Future<void> _onToggleRepeat(ToggleRepeat event, Emitter<PlayerState> emit) async {
    RepeatMode newMode;
    switch (state.repeatMode) {
      case RepeatMode.off:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        newMode = RepeatMode.off;
        break;
    }
    emit(state.copyWith(repeatMode: newMode));
  }

  Future<void> _onAddToQueue(AddToQueue event, Emitter<PlayerState> emit) async {
    await _playerService.addToQueue(event.track);
    final newQueue = List<Track>.from(state.queue)..add(event.track);
    final newOriginalQueue = List<Track>.from(state.originalQueue)..add(event.track);
    emit(state.copyWith(queue: newQueue, originalQueue: newOriginalQueue));
  }

  Future<void> _onRemoveFromQueue(RemoveFromQueue event, Emitter<PlayerState> emit) async {
    if (event.index == state.currentIndex) return; // Can't remove playing track
    
    final newQueue = List<Track>.from(state.queue)..removeAt(event.index);
    final newOriginalQueue = List<Track>.from(state.originalQueue)..removeAt(event.index);
    
    int newIndex = state.currentIndex;
    if (event.index < state.currentIndex) {
      newIndex--;
    }
    
    emit(state.copyWith(
      queue: newQueue, 
      originalQueue: newOriginalQueue,
      currentIndex: newIndex,
    ));
  }

  Future<void> _onClearQueue(ClearQueue event, Emitter<PlayerState> emit) async {
    await _playerService.stop();
    emit(const PlayerState());
  }

  Future<void> _onReorderQueue(ReorderQueue event, Emitter<PlayerState> emit) async {
    final newQueue = List<Track>.from(state.queue);
    final item = newQueue.removeAt(event.oldIndex);
    newQueue.insert(event.newIndex, item);
    
    // Update current index if needed
    int newIndex = state.currentIndex;
    if (event.oldIndex == state.currentIndex) {
      newIndex = event.newIndex;
    } else if (event.oldIndex < state.currentIndex && event.newIndex >= state.currentIndex) {
      newIndex--;
    } else if (event.oldIndex > state.currentIndex && event.newIndex <= state.currentIndex) {
      newIndex++;
    }
    
    emit(state.copyWith(queue: newQueue, currentIndex: newIndex));
  }

  Future<void> _onPlayFromQueue(PlayFromQueue event, Emitter<PlayerState> emit) async {
    if (event.index >= 0 && event.index < state.queue.length) {
      await _playerService.seek(Duration.zero);
      // Using setQueue to change track
      await _playerService.setQueue(state.queue, startIndex: event.index);
      await _playerService.play();
    }
  }

  Future<void> _onPlayerStateChanged(PlayerStateChanged event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(
      currentTrack: _playerService.currentTrack,
      queue: _playerService.queue,
      currentIndex: _playerService.currentIndex,
      isPlaying: _playerService.isPlaying,
    ));
  }

  @override
  Future<void> close() {
    _playerService.removeListener(_onPlayerStateChangedInternal);
    return super.close();
  }
}
