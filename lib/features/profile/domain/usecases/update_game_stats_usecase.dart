import '../repositories/profile_repository.dart';

class UpdateGameStatsUseCase {
  final ProfileRepository repository;

  UpdateGameStatsUseCase(this.repository);

  Future<void> call({
    required String gameType,
    required int score,
    required int playTime,
  }) async {
    await repository.addGameResult(
      gameType: gameType,
      score: score,
      playTime: playTime,
    );
  }
}