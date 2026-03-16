import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../bloc/track/track_bloc.dart';
import '../../bloc/player/player_bloc.dart';
import '../../bloc/playlist/playlist_bloc.dart';
import '../../models/track_model.dart';
import '../../widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<TrackBloc>().add(LoadTracks());
    context.read<PlaylistBloc>().add(LoadPlaylists());
    context.read<TrackBloc>().add(LoadRecentlyPlayed());
    context.read<TrackBloc>().add(LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TrackBloc>().add(LoadTracks());
            context.read<PlaylistBloc>().add(LoadPlaylists());
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text('SoundWave'),
                  ],
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.history), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                ],
              ),
              
              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getGreeting()} 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What would you like to listen to?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildQuickAction(context, Icons.add, 'Upload'),
                      const SizedBox(width: 12),
                      _buildQuickAction(context, Icons.playlist_add, 'Create Playlist'),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Recently Played Section
              BlocBuilder<TrackBloc, TrackState>(
                builder: (context, state) {
                  if (state is TrackLoaded && state.recentlyPlayed.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildSection(
                        context,
                        title: 'Recently Played',
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.recentlyPlayed.length,
                            itemBuilder: (context, index) {
                              return _buildRecentlyPlayedCard(context, state.recentlyPlayed[index]);
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Liked Songs Section
              BlocBuilder<TrackBloc, TrackState>(
                builder: (context, state) {
                  if (state is TrackLoaded && state.favorites.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildSection(
                        context,
                        title: 'Liked Songs',
                        child: SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.favorites.length > 10 ? 10 : state.favorites.length,
                            itemBuilder: (context, index) {
                              return _buildLikedSongCard(context, state.favorites[index]);
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Your Playlists Section
              BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, state) {
                  if (state is PlaylistsLoaded && state.playlists.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildSection(
                        context,
                        title: 'Your Playlists',
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.playlists.length,
                            itemBuilder: (context, index) {
                              return _buildPlaylistCard(context, state.playlists[index]);
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // All Tracks Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Tracks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.read<TrackBloc>().add(LoadTracks()),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ),

              // Tracks List
              BlocBuilder<TrackBloc, TrackState>(
                builder: (context, state) {
                  if (state is TrackLoading) {
                    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                  }
                  
                  if (state is TrackLoaded) {
                    if (state.tracks.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_off, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 16),
                              Text('No tracks yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadTrack),
                                icon: const Icon(Icons.add),
                                label: const Text('Upload Track'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.tracks.length) return null;
                          final track = state.tracks[index];
                          return TrackTile(
                            track: track,
                            onTap: () => context.read<PlayerBloc>().add(PlayQueue(state.tracks, startIndex: index)),
                            isFavorite: state.favorites.any((t) => t.id == track.id),
                            onFavoriteToggle: () => context.read<TrackBloc>().add(ToggleFavorite(track)),
                          );
                        },
                        childCount: state.tracks.length,
                      ),
                    );
                  }
                  
                  if (state is TrackError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text('Error: ${state.message}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<TrackBloc>().add(LoadTracks()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (label == 'Upload') {
            Navigator.pushNamed(context, AppRoutes.uploadTrack);
          } else {
            Navigator.pushNamed(context, AppRoutes.createPlaylist);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecentlyPlayedCard(BuildContext context, Track track) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(PlayTrack(track)),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                image: track.artwork != null
                    ? DecorationImage(image: NetworkImage(track.artwork!), fit: BoxFit.cover)
                    : null,
              ),
              child: track.artwork == null
                  ? const Icon(Icons.music_note, size: 48, color: AppColors.textMuted)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedSongCard(BuildContext context, Track track) {
    return GestureDetector(
      onTap: () => context.read<PlayerBloc>().add(PlayTrack(track)),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(BuildContext context, dynamic playlist) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.playlistDetail, arguments: playlist.id),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.playlist_play, color: Colors.white),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playlist.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${playlist.trackCount ?? 0} tracks', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
