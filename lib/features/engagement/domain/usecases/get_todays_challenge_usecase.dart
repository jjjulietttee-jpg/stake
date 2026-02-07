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
      await dailyResetService.checkAndPerformDailyReset();

      var challenge = await repository.getTodaysChallenge();

      if (challenge == null) {
        final today = DateTime.now();
        challenge = challengeGenerator.generateChallenge(today);

        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysChallenge(
            challenge,
          );
        }
      }

      return challenge;
    } catch (e) {
      try {
        final today = DateTime.now();
        final fallbackChallenges = challengeGenerator.getFallbackChallenges(
          today,
        );
        return fallbackChallenges.isNotEmpty ? fallbackChallenges.first : null;
      } catch (fallbackError) {
        return null;
      }
    }
  }
}
