import '../../features/profile/domain/repositories/profile_repository.dart';

class GameCompletionService {
  final ProfileRepository profileRepository;

  GameCompletionService({required this.profileRepository});

  Future<void> onGameCompleted({
    required String gameType,
    required int score,
    required Duration playTime,
  }) async {
    try {
      await profileRepository.addGameResult(
        gameType: gameType,
        score: score,
        playTime: playTime.inSeconds,
      );
      print('🏆 Game completion recorded: $gameType, Score: $score, Time: ${playTime.inSeconds}s');
    } catch (e) {
      print('❌ Failed to record game completion: $e');
    }
  }
}