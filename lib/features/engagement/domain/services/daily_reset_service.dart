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

  /// Check if daily reset is needed and perform it if necessary
  Future<bool> checkAndPerformDailyReset() async {
    try {
      final shouldReset = await repository.shouldResetDaily();
      if (shouldReset) {
        await performDailyReset();
        return true;
      }
      return false;
    } catch (e) {
      // Log error in production app
      return false;
    }
  }

  /// Perform daily reset operations
  Future<void> performDailyReset() async {
    try {
      final now = DateTime.now();

      // Update streak before clearing daily data
      await _updateStreakOnReset();

      // Clear previous day's data
      await repository.resetDailyData();

      // Generate new daily challenge
      await _generateNewChallenge(now);

      // Generate new bonus content
      await _generateNewBonusContent(now);

      // Update last reset date
      await repository.updateLastResetDate(now);
    } catch (e) {
      // Log error in production app
      rethrow;
    }
  }

  /// Update user's streak based on previous day's activity
  Future<void> _updateStreakOnReset() async {
    try {
      final profile = await repository.getEngagementProfile();
      final lastResetDate = await repository.getLastResetDate();

      if (lastResetDate == null) {
        // First time user, no streak to update
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

      // Check if user was active yesterday
      final wasActiveYesterday =
          _isSameDay(profile.lastEngagementDate, yesterday) ||
          _isSameDay(profile.lastEngagementDate, lastReset);

      int newCurrentStreak;
      int newLongestStreak = profile.longestStreak;

      if (wasActiveYesterday) {
        // Continue streak
        newCurrentStreak = profile.currentStreak + 1;
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
        }
      } else {
        // Streak broken
        newCurrentStreak = 0;
      }

      final updatedProfile = profile.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
      );

      await repository.updateEngagementProfile(updatedProfile);
    } catch (e) {
      // Log error in production app
      // Don't rethrow to avoid blocking daily reset
    }
  }

  /// Generate new daily challenge
  Future<void> _generateNewChallenge(DateTime date) async {
    try {
      final challenge = challengeGenerator.generateChallenge(date);

      // Save challenge using repository helper method
      if (repository is EngagementRepositoryImpl) {
        await (repository as EngagementRepositoryImpl).saveTodaysChallenge(
          challenge,
        );
      }
    } catch (e) {
      // If challenge generation fails, try fallback
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
        // Log both errors in production app
        rethrow;
      }
    }
  }

  /// Generate new bonus content
  Future<void> _generateNewBonusContent(DateTime date) async {
    try {
      final bonusContent = bonusContentProvider.generateDailyContent(date);

      // Save bonus content using repository helper method
      if (repository is EngagementRepositoryImpl) {
        await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
          bonusContent,
        );
      }
    } catch (e) {
      // If bonus content generation fails, try fallback
      try {
        final fallbackContent = bonusContentProvider.getFallbackContent(date);
        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
            fallbackContent,
          );
        }
      } catch (fallbackError) {
        // Log both errors in production app
        rethrow;
      }
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Force reset for testing purposes
  Future<void> forceReset() async {
    await performDailyReset();
  }
}
