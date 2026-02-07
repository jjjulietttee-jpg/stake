import 'package:stake/features/engagement/data/repositories/engagement_repository_impl.dart';

import '../entities/daily_challenge.dart';
import '../entities/daily_bonus_content.dart';
import '../entities/engagement_profile.dart';
import '../repositories/engagement_repository.dart';
import 'challenge_generator.dart';
import 'bonus_content_provider.dart';

class DailyResetService {
  final EngagementRepository repository;
  final ChallengeGenerator challengeGenerator;
  final BonusContentProvider bonusContentProvider;

  DailyResetService({
    required this.repository,
    required this.challengeGenerator,
    required this.bonusContentProvider,
  });

  Future<bool> checkAndPerformDailyReset() async {
    try {
      final shouldReset = await repository.shouldResetDaily();
      if (shouldReset) {
        await performDailyReset();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> performDailyReset() async {
    try {
      final now = DateTime.now();

      await _updateStreakOnReset();

      await repository.resetDailyData();

      await _generateNewChallenge(now);

      await _generateNewBonusContent(now);

      await repository.updateLastResetDate(now);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateStreakOnReset() async {
    try {
      final profile = await repository.getEngagementProfile();
      final lastResetDate = await repository.getLastResetDate();

      if (lastResetDate == null) {
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastReset = DateTime(
        lastResetDate.year,
        lastResetDate.month,
        lastResetDate.day,
      );
      final yesterday = today.subtract(const Duration(days: 1));

      final wasActiveYesterday =
          _isSameDay(profile.lastEngagementDate, yesterday) ||
          _isSameDay(profile.lastEngagementDate, lastReset);

      int newCurrentStreak;
      int newLongestStreak = profile.longestStreak;

      if (wasActiveYesterday) {
        newCurrentStreak = profile.currentStreak + 1;
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
        }
      } else {
        newCurrentStreak = 0;
      }

      final updatedProfile = profile.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
      );

      await repository.updateEngagementProfile(updatedProfile);
    } catch (e) {
    }
  }

  Future<void> _generateNewChallenge(DateTime date) async {
    try {
      final challenge = challengeGenerator.generateChallenge(date);

      if (repository is EngagementRepositoryImpl) {
        await (repository as EngagementRepositoryImpl).saveTodaysChallenge(
          challenge,
        );
      }
    } catch (e) {
      try {
        final fallbackChallenges = challengeGenerator.getFallbackChallenges(
          date,
        );
        if (fallbackChallenges.isNotEmpty &&
            repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysChallenge(
            fallbackChallenges.first,
          );
        }
      } catch (fallbackError) {
        rethrow;
      }
    }
  }

  Future<void> _generateNewBonusContent(DateTime date) async {
    try {
      final bonusContent = bonusContentProvider.generateDailyContent(date);

      if (repository is EngagementRepositoryImpl) {
        await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
          bonusContent,
        );
      }
    } catch (e) {
      try {
        final fallbackContent = bonusContentProvider.getFallbackContent(date);
        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
            fallbackContent,
          );
        }
      } catch (fallbackError) {
        rethrow;
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> forceReset() async {
    await performDailyReset();
  }
}
