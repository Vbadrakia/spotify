import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../bloc/playlist/playlist_bloc.dart';
import '../../bloc/player/player_bloc.dart';
import '../../widgets/track_tile.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlaylistBloc>().add(LoadPlaylistDetail(widget.playlistId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlaylistDetailLoaded) {
            final playlist = state.playlist;

            return CustomScrollView(
              slivers: [
                // App Bar with Playlist Info
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      playlist.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.background,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              image: playlist.artwork != null
                                  ? DecorationImage(
                                      image: NetworkImage(playlist.artwork!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: playlist.artwork == null
                                ? const Icon(
                                    Icons.music_note,
                                    size: 60,
                                    color: AppColors.textMuted,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${playlist.tracks.length} tracks',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Play All Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: playlist.tracks.isNotEmpty
                                ? () {
                                    context.read<PlayerBloc>().add(PlayQueue(playlist.tracks));
                                  }
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play All'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          onPressed: playlist.tracks.isNotEmpty
                              ? () {
                                  final shuffled = List.of(playlist.tracks)..shuffle();
                                  context.read<PlayerBloc>().add(PlayQueue(shuffled));
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tracks List
                if (playlist.tracks.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tracks in this playlist',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final track = playlist.tracks[index];
                        return TrackTile(
                          track: track,
                          onTap: () {
                            context.read<PlayerBloc>().add(
                              PlayQueue(playlist.tracks, startIndex: index),
                            );
                          },
                          showRemove: true,
                          onRemove: () {
                            context.read<PlaylistBloc>().add(
                              RemoveTrackFromPlaylist(
                                playlistId: playlist.id,
                                trackId: track.id,
                              ),
                            );
                          },
                        );
                      },
                      childCount: playlist.tracks.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }

          if (state is PlaylistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlaylistBloc>().add(LoadPlaylistDetail(widget.playlistId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
