import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_achievements_usecase.dart';
import '../../domain/usecases/update_game_stats_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetAchievementsUseCase getAchievementsUseCase;
  final UpdateGameStatsUseCase updateGameStatsUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.getAchievementsUseCase,
    required this.updateGameStatsUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LoadProfileOnly>(_onLoadProfileOnly);
    on<LoadAchievements>(_onLoadAchievements);
    on<LoadAchievementsOnly>(_onLoadAchievementsOnly);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateGameStats>(_onUpdateGameStats);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      
      final userProfile = await getUserProfileUseCase();
      final achievements = await getAchievementsUseCase();
      
      emit(ProfileLoaded(
        userProfile: userProfile,
        achievements: achievements,
      ));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProfileOnly(LoadProfileOnly event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      
      final userProfile = await getUserProfileUseCase();
      
      emit(ProfileOnlyLoaded(userProfile: userProfile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAchievements(LoadAchievements event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      try {
        final currentState = state as ProfileLoaded;
        final achievements = await getAchievementsUseCase();
        
        emit(currentState.copyWith(achievements: achievements));
      } catch (e) {
        emit(ProfileError('Failed to load achievements: ${e.toString()}'));
      }
    } else if (state is ProfileOnlyLoaded) {
      try {
        final currentState = state as ProfileOnlyLoaded;
        final achievements = await getAchievementsUseCase();
        
        emit(ProfileLoaded(
          userProfile: currentState.userProfile,
          achievements: achievements,
        ));
      } catch (e) {
        emit(ProfileError('Failed to load achievements: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadAchievementsOnly(LoadAchievementsOnly event, Emitter<ProfileState> emit) async {
    try {
      emit(const ProfileLoading());
      
      final achievements = await getAchievementsUseCase();
      
      emit(AchievementsOnlyLoaded(achievements: achievements));
    } catch (e) {
      emit(ProfileError('Failed to load achievements: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshProfile(RefreshProfile event, Emitter<ProfileState> emit) async {
    try {
      final userProfile = await getUserProfileUseCase();
      final achievements = await getAchievementsUseCase();
      
      emit(ProfileLoaded(
        userProfile: userProfile,
        achievements: achievements,
      ));
    } catch (e) {
      emit(ProfileError('Failed to refresh profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateGameStats(UpdateGameStats event, Emitter<ProfileState> emit) async {
    try {
      await updateGameStatsUseCase(
        gameType: event.gameType,
        score: event.score,
        playTime: event.playTime,
      );
      
      add(const RefreshProfile());
    } catch (e) {
      emit(ProfileError('Failed to update game stats: ${e.toString()}'));
    }
  }
}