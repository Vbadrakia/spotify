import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../models/track_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  
  List<Track> _queue = [];
  int _currentIndex = 0;
  final List<void Function()> _listeners = [];

  AudioPlayer get player => _player;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  Track? get currentTrack => _queue.isNotEmpty && _currentIndex < _queue.length 
      ? _queue[_currentIndex] 
      : null;
  
  bool get isPlaying => _player.playing;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  AudioPlayerService() {
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        _notifyListeners();
      }
    });
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue = tracks;
    _currentIndex = startIndex;
    
    final audioSources = tracks.asMap().entries.map((entry) {
      return AudioSource.uri(
        Uri.parse(entry.value.audioUrl),
        tag: entry.value,
      );
    }).toList();
    
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: startIndex,
    );
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> playNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  Future<void> playTrack(Track track) async {
    await setQueue([track]);
    await play();
  }

  Future<void> addToQueue(Track track) async {
    _queue.add(track);
    await _player.setAudioSource(
      ConcatenatingAudioSource(children: _queue.asMap().entries.map((e) {
        return AudioSource.uri(
          Uri.parse(e.value.audioUrl),
          tag: e.value,
        );
      }).toList()),
      initialIndex: _currentIndex,
    );
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (_currentIndex >= index && _currentIndex > 0) {
        _currentIndex--;
      }
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
