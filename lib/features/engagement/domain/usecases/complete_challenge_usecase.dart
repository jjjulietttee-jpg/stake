import '../entities/daily_challenge.dart';
import '../entities/engagement_profile.dart';
import '../repositories/engagement_repository.dart';
import '../services/engagement_analytics.dart';

class CompleteChallengeUseCase {
  final EngagementRepository repository;
  final EngagementAnalytics analytics;

  CompleteChallengeUseCase({
    required this.repository,
    required this.analytics,
  });

  Future<bool> call({
    required String challengeId,
    required DateTime completedAt,
  }) async {
    try {
      final challenge = await repository.getTodaysChallenge();
      
      if (challenge == null || challenge.id != challengeId) {
        return false; // Challenge not found or ID mismatch
      }
      
      if (challenge.isCompleted) {
        return false; // Challenge already completed
      }
      
      await repository.markChallengeCompleted(challengeId);
      
      await _updateEngagementProfile(challenge, completedAt);
      
      await analytics.recordChallengeCompleted(
        challengeId: challengeId,
        challengeType: challenge.type,
        challengeTitle: challenge.title,
        completedAt: completedAt,
        timeToComplete: completedAt.difference(DateTime.now().subtract(const Duration(hours: 1))), // Approximate
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateEngagementProfile(DailyChallenge challenge, DateTime completedAt) async {
    try {
      final profile = await repository.getEngagementProfile();
      
      final updatedChallengeStats = Map<String, int>.from(profile.challengeTypeStats);
      final challengeTypeKey = challenge.type.name;
      updatedChallengeStats[challengeTypeKey] = (updatedChallengeStats[challengeTypeKey] ?? 0) + 1;
      
      final today = DateTime.now();
      final isFirstEngagementToday = !_isSameDay(profile.lastEngagementDate, today);
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (isFirstEngagementToday) {
        final yesterday = today.subtract(const Duration(days: 1));
        final wasActiveYesterday = _isSameDay(profile.lastEngagementDate, yesterday);
        
        if (wasActiveYesterday || profile.currentStreak == 0) {
          newCurrentStreak = profile.currentStreak + 1;
        } else {
          newCurrentStreak = 1;
        }
        
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
          await analytics.recordStreakMilestone(
            streakLength: newCurrentStreak,
            achievedAt: completedAt,
          );
        }
      }
      
      final updatedProfile = profile.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        totalChallengesCompleted: profile.totalChallengesCompleted + 1,
        lastEngagementDate: completedAt,
        challengeTypeStats: updatedChallengeStats,
      );
      
      await repository.updateEngagementProfile(updatedProfile);
      
      await analytics.recordDailyEngagement(
        sessionDate: completedAt,
        challengeCompleted: true,
        bonusContentViewed: 0, // Will be updated separately
        currentStreak: newCurrentStreak,
      );
      
    } catch (e) {
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}