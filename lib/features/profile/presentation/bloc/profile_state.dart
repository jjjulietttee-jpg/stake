import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/achievement.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileOnlyLoaded extends ProfileState {
  final UserProfile userProfile;

  const ProfileOnlyLoaded({
    required this.userProfile,
  });

  @override
  List<Object?> get props => [userProfile];
}

class AchievementsOnlyLoaded extends ProfileState {
  final List<Achievement> achievements;

  const AchievementsOnlyLoaded({
    required this.achievements,
  });

  @override
  List<Object?> get props => [achievements];
}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  final List<Achievement> achievements;

  const ProfileLoaded({
    required this.userProfile,
    required this.achievements,
  });

  ProfileLoaded copyWith({
    UserProfile? userProfile,
    List<Achievement>? achievements,
  }) {
    return ProfileLoaded(
      userProfile: userProfile ?? this.userProfile,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object?> get props => [userProfile, achievements];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}