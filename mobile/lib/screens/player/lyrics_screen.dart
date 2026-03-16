import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../bloc/track/track_bloc.dart';
import '../../models/track_model.dart';

class LyricsScreen extends StatefulWidget {
  final Track track;

  const LyricsScreen({super.key, required this.track});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  @override
  void initState() {
    super.initState();
    // Try to load lyrics from track or fetch from API
    if (widget.track.lyrics == null || widget.track.lyrics!.isEmpty) {
      context.read<TrackBloc>().add(LoadLyrics(widget.track.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocalLyrics = widget.track.hasLyrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditLyricsDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<TrackBloc, TrackState>(
        builder: (context, state) {
          // Show local lyrics first
          if (hasLocalLyrics) {
            return _buildLyricsView(context, widget.track.lyrics!);
          }

          // Loading from API
          if (state is LyricsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // No lyrics available
          if (state is TrackError || !hasLocalLyrics) {
            return _buildNoLyricsView(context);
          }

          return _buildNoLyricsView(context);
        },
      ),
    );
  }

  Widget _buildLyricsView(BuildContext context, String lyrics) {
    final lines = lyrics.split('\n');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: widget.track.artwork != null
                      ? DecorationImage(image: NetworkImage(widget.track.artwork!), fit: BoxFit.cover)
                      : null,
                ),
                child: widget.track.artwork == null
                    ? const Icon(Icons.music_note, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(widget.track.artist, style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Lyrics
          if (lines.isEmpty)
            const Center(child: Text('No lyrics available'))
          else
            ...lines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value.trim();
              
              if (line.isEmpty) {
                return const SizedBox(height: 16);
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),

          const SizedBox(height: 40),
          Center(
            child: Text(
              '🎵',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLyricsView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lyrics, size: 60, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Lyrics Available',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Unfortunately, lyrics for this track are not available.\nYou can add them manually!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showEditLyricsDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Lyrics'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLyricsDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.track.lyrics ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add/Edit Lyrics'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste or write lyrics here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, you would call an API to save lyrics
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lyrics saved! (API integration needed)')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
