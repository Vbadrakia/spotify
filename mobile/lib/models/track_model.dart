import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artwork;
  final String audioUrl;
  final int duration;
  final String? lyrics;
  final String uploadedBy;
  final String? uploadedByName;
  final int playCount;
  final DateTime createdAt;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.artwork,
    required this.audioUrl,
    required this.duration,
    this.lyrics,
    required this.uploadedBy,
    this.uploadedByName,
    this.playCount = 0,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'],
      artwork: json['artwork'],
      audioUrl: json['audioUrl'] ?? json['audio_url'] ?? '',
      duration: json['duration'] ?? 0,
      lyrics: json['lyrics'],
      uploadedBy: json['uploadedBy'] ?? json['uploaded_by'] ?? '',
      uploadedByName: json['uploadedByName'] ?? json['uploaded_by_name'],
      playCount: json['playCount'] ?? json['play_count'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artwork': artwork,
      'audioUrl': audioUrl,
      'duration': duration,
      'lyrics': lyrics,
      'uploadedBy': uploadedBy,
      'playCount': playCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artwork,
    String? audioUrl,
    int? duration,
    String? lyrics,
    String? uploadedBy,
    String? uploadedByName,
    int? playCount,
    DateTime? createdAt,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artwork: artwork ?? this.artwork,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      lyrics: lyrics ?? this.lyrics,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get hasLyrics => lyrics != null && lyrics!.isNotEmpty;

  @override
  List<Object?> get props => [id, title, artist, album, artwork, audioUrl, duration, lyrics, uploadedBy, playCount];
}
