import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../bloc/track/track_bloc.dart';

class UploadTrackScreen extends StatefulWidget {
  const UploadTrackScreen({super.key});

  @override
  State<UploadTrackScreen> createState() => _UploadTrackScreenState();
}

class _UploadTrackScreenState extends State<UploadTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _lyricsController = TextEditingController();
  
  String? _audioPath;
  String? _artworkPath;
  String? _audioFileName;
  bool _showLyrics = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _audioPath = result!.files.single.path;
          _audioFileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickArtwork() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _artworkPath = image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _uploadTrack() {
    if (_formKey.currentState!.validate()) {
      if (_audioPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an audio file'), backgroundColor: AppColors.error),
        );
        return;
      }

      context.read<TrackBloc>().add(UploadTrack(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim().isNotEmpty ? _albumController.text.trim() : null,
        audioFilePath: _audioPath!,
        artworkFilePath: _artworkPath,
        lyrics: _lyricsController.text.trim().isNotEmpty ? _lyricsController.text.trim() : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Track'),
      ),
      body: BlocListener<TrackBloc, TrackState>(
        listener: (context, state) {
          if (state is TrackUploadSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Track uploaded successfully!')),
            );
          } else if (state is TrackError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Artwork
                GestureDetector(
                  onTap: _pickArtwork,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      image: _artworkPath != null ? DecorationImage(image: FileImage(File(_artworkPath!)), fit: BoxFit.cover) : null,
                    ),
                    child: _artworkPath == null
                        ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text('Add Artwork (optional)', style: TextStyle(color: AppColors.textMuted)),
                          ])
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Audio File
                GestureDetector(
                  onTap: _pickAudio,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _audioPath == null ? AppColors.textMuted : AppColors.primary, width: 2),
                    ),
                    child: Column(children: [
                      Icon(_audioPath == null ? Icons.audio_file : Icons.check_circle, size: 48,
                          color: _audioPath == null ? AppColors.textMuted : AppColors.primary),
                      const SizedBox(height: 8),
                      Text(_audioPath == null ? 'Tap to select audio file' : _audioFileName ?? 'Audio selected',
                          style: TextStyle(color: _audioPath == null ? AppColors.textMuted : AppColors.primary),
                          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.music_note)),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),

                // Artist
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artist *', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter an artist' : null,
                ),
                const SizedBox(height: 16),

                // Album
                TextFormField(
                  controller: _albumController,
                  decoration: const InputDecoration(labelText: 'Album (optional)', prefixIcon: Icon(Icons.album)),
                ),
                const SizedBox(height: 16),

                // Lyrics Toggle
                GestureDetector(
                  onTap: () => setState(() => _showLyrics = !_showLyrics),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Icon(Icons.lyrics, color: _showLyrics ? AppColors.primary : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Add Lyrics')),
                      Switch(value: _showLyrics, onChanged: (v) => setState(() => _showLyrics = v), activeColor: AppColors.primary),
                    ]),
                  ),
                ),

                // Lyrics Field
                if (_showLyrics) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lyricsController,
                    decoration: const InputDecoration(
                      labelText: 'Lyrics',
                      prefixIcon: Icon(Icons.format_list_numbered),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text('Paste lyrics or write them here', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],

                const SizedBox(height: 32),

                // Upload Button
                BlocBuilder<TrackBloc, TrackState>(
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      onPressed: state is TrackUploading ? null : _uploadTrack,
                      icon: state is TrackUploading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload),
                      label: Text(state is TrackUploading ? 'Uploading...' : 'Upload Track'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
