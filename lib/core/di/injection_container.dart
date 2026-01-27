import 'package:get_it/get_it.dart';
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
import '../services/game_completion_service.dart';

final sl = GetIt.instance;
final getIt = GetIt.instance;

Future<void> init() async {
  // Core Services
  _initServices();
  
  // Memory Game
  _initMemoryGame();
  
  // Profile
  _initProfile();
}

void _initServices() {
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