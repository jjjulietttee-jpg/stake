import 'package:stake/features/engagement/data/repositories/engagement_repository_impl.dart';

import '../entities/daily_challenge.dart';
import '../repositories/engagement_repository.dart';
import '../services/challenge_generator.dart';
import '../services/daily_reset_service.dart';

class GetTodaysChallengeUseCase {
  final EngagementRepository repository;
  final ChallengeGenerator challengeGenerator;
  final DailyResetService dailyResetService;

  GetTodaysChallengeUseCase({
    required this.repository,
    required this.challengeGenerator,
    required this.dailyResetService,
  });

  Future<DailyChallenge?> call() async {
    try {
      // Check if daily reset is needed
      await dailyResetService.checkAndPerformDailyReset();

      // Try to get existing challenge
      var challenge = await repository.getTodaysChallenge();

      // If no challenge exists, generate one
      if (challenge == null) {
        final today = DateTime.now();
        challenge = challengeGenerator.generateChallenge(today);

        // Save the generated challenge
        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysChallenge(
            challenge,
          );
        }
      }

      return challenge;
    } catch (e) {
      // If all else fails, try to get a fallback challenge
      try {
        final today = DateTime.now();
        final fallbackChallenges = challengeGenerator.getFallbackChallenges(
          today,
        );
        return fallbackChallenges.isNotEmpty ? fallbackChallenges.first : null;
      } catch (fallbackError) {
        // Log both errors in production
        return null;
      }
    }
  }
}
