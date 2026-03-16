import 'package:equatable/equatable.dart';
import 'track_model.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? artwork;
  final List<Track> tracks;
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;
  final int trackCount;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.artwork,
    this.tracks = const [],
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.trackCount = 0,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      artwork: json['artwork'],
      tracks: json['tracks'] != null 
          ? (json['tracks'] as List).map((t) => Track.fromJson(t)).toList()
          : [],
      createdBy: json['createdBy'] ?? json['created_by'] ?? '',
      createdByName: json['createdByName'] ?? json['created_by_name'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      trackCount: json['trackCount'] ?? json['track_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'artwork': artwork,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? artwork,
    List<Track>? tracks,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    int? trackCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artwork: artwork ?? this.artwork,
      tracks: tracks ?? this.tracks,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      trackCount: trackCount ?? this.trackCount,
    );
  }

  @override
  List<Object?> get props => [id, name, description, artwork, tracks, createdBy, createdAt];
}
