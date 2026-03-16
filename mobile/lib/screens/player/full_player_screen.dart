import 'dart:async';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../bloc/player/player_bloc.dart';
import '../../bloc/track/track_bloc.dart';
import '../../models/track_model.dart';
import 'lyrics_screen.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> {
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() {
    final playerBloc = context.read<PlayerBloc>();
    _positionSubscription = playerBloc.playerService.positionStream.listen((_) {
      if (mounted) setState(() {});
    });
    _durationSubscription = playerBloc.playerService.durationStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () => _showQueueBottomSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state.currentTrack == null) {
            return const Center(child: Text('No track playing'));
          }

          final track = state.currentTrack!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Artwork
                  GestureDetector(
                    onTap: track.hasLyrics ? () => _openLyrics(context, track) : null,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: track.artwork != null
                                ? DecorationImage(image: NetworkImage(track.artwork!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: track.artwork == null
                              ? const Icon(Icons.music_note, size: 100, color: AppColors.textMuted)
                              : null,
                        ),
                        // Lyrics indicator
                        if (track.hasLyrics)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lyrics, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('Lyrics', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Track Info
                  Column(
                    children: [
                      Text(
                        track.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        track.artist,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar
                  _buildProgressBar(context, state, track),

                  const SizedBox(height: 16),

                  // Controls
                  _buildControls(context, state),

                  const SizedBox(height: 24),

                  // Extra Controls
                  _buildExtraControls(context, state, track),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerState state, Track track) {
    return StreamBuilder<Duration>(
      stream: context.read<PlayerBloc>().playerService.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = Duration(seconds: track.duration);
        
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble().clamp(1, double.infinity),
                onChanged: (value) {
                  context.read<PlayerBloc>().add(SeekTo(Duration(seconds: value.toInt())));
                },
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceVariant,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position), style: Theme.of(context).textTheme.bodySmall),
                  Text(_formatDuration(duration), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, PlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle, color: state.isShuffle ? AppColors.primary : AppColors.textSecondary),
          onPressed: () => context.read<PlayerBloc>().add(ToggleShuffle()),
        ),
        IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: () => context.read<PlayerBloc>().add(PlayPrevious())),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white),
            onPressed: () => context.read<PlayerBloc>().add(TogglePlayPause()),
          ),
        ),
        IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: () => context.read<PlayerBloc>().add(PlayNext())),
        IconButton(
          icon: Icon(
            state.repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
            color: state.repeatMode != RepeatMode.off ? AppColors.primary : AppColors.textSecondary,
          ),
          onPressed: () => context.read<PlayerBloc>().add(ToggleRepeat()),
        ),
      ],
    );
  }

  Widget _buildExtraControls(BuildContext context, PlayerState state, Track track) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Favorite
        BlocBuilder<TrackBloc, TrackState>(
          builder: (context, trackState) {
            final isFavorite = trackState is TrackLoaded && trackState.favorites.any((t) => t.id == track.id);
            return IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.accent : null),
              onPressed: () => context.read<TrackBloc>().add(ToggleFavorite(track)),
            );
          },
        ),

        // Lyrics Button
        IconButton(
          icon: Icon(Icons.lyrics, color: track.hasLyrics ? AppColors.primary : AppColors.textSecondary),
          onPressed: track.hasLyrics ? () => _openLyrics(context, track) : null,
          tooltip: 'View Lyrics',
        ),

        // Volume
        Row(children: [
          const Icon(Icons.volume_down, size: 20, color: AppColors.textSecondary),
          SizedBox(
            width: 100,
            child: Slider(
              value: state.volume,
              onChanged: (value) => context.read<PlayerBloc>().add(SetVolume(value)),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceVariant,
            ),
          ),
          const Icon(Icons.volume_up, size: 20, color: AppColors.textSecondary),
        ]),

        // Share
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing coming soon!'))),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _openLyrics(BuildContext context, Track track) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LyricsScreen(track: track)),
    );
  }

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Queue', style: Theme.of(context).textTheme.titleLarge),
                        if (state.queue.isNotEmpty)
                          TextButton(onPressed: () { context.read<PlayerBloc>().add(ClearQueue()); Navigator.pop(context); }, child: const Text('Clear')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.queue.isEmpty
                          ? const Center(child: Text('Queue is empty'))
                          : ReorderableListView.builder(
                              scrollController: scrollController,
                              itemCount: state.queue.length,
                              onReorder: (oldIndex, newIndex) {
                                if (newIndex > oldIndex) newIndex--;
                                context.read<PlayerBloc>().add(ReorderQueue(oldIndex: oldIndex, newIndex: newIndex));
                              },
                              itemBuilder: (context, index) {
                                final track = state.queue[index];
                                final isPlaying = index == state.currentIndex;
                                return ListTile(
                                  key: ValueKey('$index-${track.id}'),
                                  leading: isPlaying ? const Icon(Icons.play_arrow, color: AppColors.primary) : Text('${index + 1}'),
                                  title: Text(track.title, style: TextStyle(color: isPlaying ? AppColors.primary : null, fontWeight: isPlaying ? FontWeight.bold : null)),
                                  subtitle: Text(track.artist),
                                  trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => context.read<PlayerBloc>().add(RemoveFromQueue(index))),
                                  onTap: () => context.read<PlayerBloc>().add(PlayFromQueue(index)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
