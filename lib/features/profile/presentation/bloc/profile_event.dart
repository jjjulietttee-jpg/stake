import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class LoadProfileOnly extends ProfileEvent {
  const LoadProfileOnly();
}

class LoadAchievements extends ProfileEvent {
  const LoadAchievements();
}

class LoadAchievementsOnly extends ProfileEvent {
  const LoadAchievementsOnly();
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

class UpdateGameStats extends ProfileEvent {
  final String gameType;
  final int score;
  final int playTime;

  const UpdateGameStats({
    required this.gameType,
    required this.score,
    required this.playTime,
  });

  @override
  List<Object?> get props => [gameType, score, playTime];
}