import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/memory_game/data/repositories/memory_game_repository_impl.dart';
import '../../features/memory_game/domain/repositories/memory_game_repository.dart';
import '../../features/memory_game/domain/usecases/start_game_usecase.dart';
import '../../features/memory_game/domain/usecases/calculate_score_usecase.dart';
import '../../features/memory_game/presentation/bloc/memory_game_bloc.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_achievements_usecase.dart';
import '../../features/profile/domain/usecases/update_game_stats_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/engagement/data/datasources/engagement_local_data_source.dart';
import '../../features/engagement/data/repositories/engagement_repository_impl.dart';
import '../../features/engagement/domain/repositories/engagement_repository.dart';
import '../../features/engagement/domain/services/challenge_generator.dart';
import '../../features/engagement/domain/services/bonus_content_provider.dart';
import '../../features/engagement/domain/services/daily_reset_service.dart';
import '../../features/engagement/domain/services/engagement_analytics.dart';
import '../../features/engagement/domain/services/engagement_service.dart';
import '../../features/engagement/domain/usecases/get_todays_challenge_usecase.dart';
import '../../features/engagement/domain/usecases/complete_challenge_usecase.dart';
import '../../features/engagement/domain/usecases/update_streak_usecase.dart';
import '../../features/engagement/domain/usecases/get_todays_bonus_content_usecase.dart';
import '../../features/engagement/domain/usecases/mark_bonus_viewed_usecase.dart';
import '../../features/engagement/presentation/bloc/daily_challenge_bloc.dart';
import '../../features/engagement/presentation/bloc/daily_bonus_bloc.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../services/game_completion_service.dart';
import '../services/storage_service.dart';

final sl = GetIt.instance;
final getIt = GetIt.instance;

Future<void> init() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core Services
  _initServices();
  
  // Memory Game
  _initMemoryGame();
  
  // Profile
  _initProfile();
  
  // Engagement Features
  _initEngagement();
  
  // Splash
  _initSplash();
}

void _initSplash() {
  // BLoC
  sl.registerFactory(
    () => SplashBloc(storageService: sl()),
  );
}

void _initServices() {
  // Storage Service
  sl.registerLazySingleton(
    () => StorageService(sl<SharedPreferences>()),
  );
  
  // Game Completion Service
  sl.registerLazySingleton(
    () => GameCompletionService(profileRepository: sl()),
  );
}

void _initMemoryGame() {
  // BLoC
  sl.registerFactory(
    () => MemoryGameBloc(
      startGameUseCase: sl(),
      calculateScoreUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => StartGameUseCase(sl()));
  sl.registerLazySingleton(() => CalculateScoreUseCase(sl()));

  // Repository
  sl.registerLazySingleton<MemoryGameRepository>(
    () => MemoryGameRepositoryImpl(),
  );
}

void _initProfile() {
  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      getAchievementsUseCase: sl(),
      updateGameStatsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGameStatsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
}

void _initEngagement() {
  // BLoCs
  sl.registerFactory(
    () => DailyChallengeBloc(
      engagementService: sl(),
    ),
  );
  
  sl.registerFactory(
    () => DailyBonusBloc(
      engagementService: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(
    () => EngagementService(
      repository: sl(),
      getTodaysChallengeUseCase: sl(),
      completeChallengeUseCase: sl(),
      updateStreakUseCase: sl(),
      getTodaysBonusContentUseCase: sl(),
      markBonusViewedUseCase: sl(),
      analytics: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => ChallengeGenerator());
  sl.registerLazySingleton(() => BonusContentProvider());
  sl.registerLazySingleton(() => EngagementAnalytics());
  
  sl.registerLazySingleton(
    () => DailyResetService(
      repository: sl(),
      challengeGenerator: sl(),
      bonusContentProvider: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetTodaysChallengeUseCase(
      repository: sl(),
      challengeGenerator: sl(),
      dailyResetService: sl(),
    ),
  );
  
  sl.registerLazySingleton(
    () => CompleteChallengeUseCase(
      repository: sl(),
      analytics: sl(),
    ),
  );
  
  sl.registerLazySingleton(
    () => UpdateStreakUseCase(
      repository: sl(),
      analytics: sl(),
    ),
  );
  
  sl.registerLazySingleton(
    () => GetTodaysBonusContentUseCase(
      repository: sl(),
      bonusContentProvider: sl(),
      dailyResetService: sl(),
    ),
  );
  
  sl.registerLazySingleton(
    () => MarkBonusViewedUseCase(
      repository: sl(),
      analytics: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<EngagementRepository>(
    () => EngagementRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<EngagementLocalDataSource>(
    () => EngagementLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
}