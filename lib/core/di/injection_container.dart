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
import '../../features/policy/policy_repository.dart';
import '../services/game_completion_service.dart';
import '../services/storage_service.dart';

final sl = GetIt.instance;
final getIt = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  _initServices();
  _initMemoryGame();
  _initProfile();
  _initEngagement();
  _initSplash();
  _initPolicy();
}

void _initPolicy() {
  sl.registerLazySingleton<PolicyStore>(
    () => const PolicyStore(),
  );
}

void _initSplash() {
  sl.registerFactory(
    () => SplashBloc(storageService: sl()),
  );
}

void _initServices() {
  sl.registerLazySingleton(
    () => StorageService(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton(
    () => GameCompletionService(profileRepository: sl()),
  );
}

void _initMemoryGame() {
  sl.registerFactory(
    () => MemoryGameBloc(
      startGameUseCase: sl(),
      calculateScoreUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => StartGameUseCase(sl()));
  sl.registerLazySingleton(() => CalculateScoreUseCase(sl()));
  sl.registerLazySingleton<MemoryGameRepository>(
    () => MemoryGameRepositoryImpl(),
  );
}

void _initProfile() {
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      getAchievementsUseCase: sl(),
      updateGameStatsUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAchievementsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGameStatsUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
}

void _initEngagement() {
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
  sl.registerLazySingleton<EngagementRepository>(
    () => EngagementRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<EngagementLocalDataSource>(
    () => EngagementLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
}