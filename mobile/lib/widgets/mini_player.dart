import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../bloc/player/player_bloc.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state.currentTrack == null) {
          return const SizedBox.shrink();
        }

        final track = state.currentTrack!;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.fullPlayer);
          },
          onVerticalDragEnd: (details) {
            // Swipe up to open full player
            if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
              Navigator.pushNamed(context, AppRoutes.fullPlayer);
            }
          },
          child: Container(
            color: AppColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: state.duration.inSeconds > 0
                      ? state.position.inSeconds / state.duration.inSeconds
                      : 0,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 2,
                ),

                // Player Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      // Artwork
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          image: track.artwork != null
                              ? DecorationImage(
                                  image: NetworkImage(track.artwork!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: track.artwork == null
                            ? const Icon(Icons.music_note, color: AppColors.textMuted, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Track Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              track.artist,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      IconButton(
                        icon: Icon(
                          state.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          context.read<PlayerBloc>().add(TogglePlayPause());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
                        onPressed: state.hasNext
                            ? () => context.read<PlayerBloc>().add(PlayNext())
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music, color: AppColors.textPrimary),
                        onPressed: () => _showQueuePreview(context, state),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQueuePreview(BuildContext context, PlayerState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Now Playing', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                state.currentTrack?.title ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                state.currentTrack?.artist ?? '',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (state.queue.length > 1) ...[
                Text('Up Next', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...state.queue
                    .skip(state.currentIndex + 1)
                    .take(3)
                    .map((track) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(track.title),
                          subtitle: Text(track.artist),
                          trailing: const Icon(Icons.play_arrow),
                          onTap: () {
                            final index = state.queue.indexOf(track);
                            context.read<PlayerBloc>().add(PlayFromQueue(index));
                          },
                        )),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRoutes.fullPlayer);
                  },
                  child: const Text('Open Full Player'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
