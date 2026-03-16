import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../bloc/playlist/playlist_bloc.dart';
import '../../bloc/track/track_bloc.dart';
import '../../bloc/player/player_bloc.dart';
import '../../models/playlist_model.dart';
import '../../widgets/track_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PlaylistBloc>().add(LoadPlaylists());
    context.read<TrackBloc>().add(LoadFavorites());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaylistsTab(),
          _buildFavoritesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createPlaylist);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        if (state is PlaylistLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is PlaylistsLoaded) {
          if (state.playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_play,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.createPlaylist);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Playlist'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.playlists.length,
            itemBuilder: (context, index) {
              final playlist = state.playlists[index];
              return _buildPlaylistTile(playlist);
            },
          );
        }
        
        if (state is PlaylistError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            image: playlist.artwork != null
                ? DecorationImage(
                    image: NetworkImage(playlist.artwork!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: playlist.artwork == null
              ? const Icon(Icons.music_note, color: AppColors.primary)
              : null,
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${playlist.trackCount} tracks',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Play All'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'play' && playlist.tracks.isNotEmpty) {
              context.read<PlayerBloc>().add(PlayQueue(playlist.tracks));
            } else if (value == 'delete') {
              _showDeleteDialog(playlist);
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.playlistDetail,
            arguments: playlist.id,
          );
        },
      ),
    );
  }

  void _showDeleteDialog(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistBloc>().add(DeletePlaylist(playlist.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return BlocBuilder<TrackBloc, TrackState>(
      builder: (context, state) {
        if (state is TrackLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is TrackLoaded) {
          if (state.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon to add favorites',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final track = state.favorites[index];
              return TrackTile(
                track: track,
                onTap: () {
                  context.read<PlayerBloc>().add(
                    PlayQueue(state.favorites, startIndex: index),
                  );
                },
                isFavorite: true,
                onFavoriteToggle: () {
                  context.read<TrackBloc>().add(ToggleFavorite(track));
                },
              );
            },
          );
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
