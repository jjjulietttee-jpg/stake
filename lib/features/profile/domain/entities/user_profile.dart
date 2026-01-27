import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final int totalScore;
  final int level;
  final int gamesPlayed;
  final int totalPlayTime; // in seconds
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final Map<String, int> gameStats; // game type -> best score

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.totalScore,
    required this.level,
    required this.gamesPlayed,
    required this.totalPlayTime,
    required this.createdAt,
    required this.lastPlayedAt,
    required this.gameStats,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? totalScore,
    int? level,
    int? gamesPlayed,
    int? totalPlayTime,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    Map<String, int>? gameStats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      gameStats: gameStats ?? this.gameStats,
    );
  }

  int get experiencePoints => totalScore;
  int get nextLevelXP => (level + 1) * 1000;
  double get levelProgress => (experiencePoints % 1000) / 1000.0;

  String get formattedPlayTime {
    final hours = totalPlayTime ~/ 3600;
    final minutes = (totalPlayTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        totalScore,
        level,
        gamesPlayed,
        totalPlayTime,
        createdAt,
        lastPlayedAt,
        gameStats,
      ];
}