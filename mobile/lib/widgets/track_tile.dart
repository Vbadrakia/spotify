import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/track_model.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showRemove;
  final VoidCallback? onRemove;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Artwork
            Container(
              width: 56,
              height: 56,
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
                  ? const Icon(
                      Icons.music_note,
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Track Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              track.formattedDuration,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),

            // Favorite Button
            if (onFavoriteToggle != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.accent : AppColors.textMuted,
                ),
                onPressed: onFavoriteToggle,
              ),

            // Remove Button
            if (showRemove && onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.error,
                ),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}
