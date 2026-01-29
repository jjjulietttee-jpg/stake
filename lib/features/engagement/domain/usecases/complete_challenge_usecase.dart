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
      // Get current challenge to verify it exists and isn't already completed
      final challenge = await repository.getTodaysChallenge();
      
      if (challenge == null || challenge.id != challengeId) {
        return false; // Challenge not found or ID mismatch
      }
      
      if (challenge.isCompleted) {
        return false; // Challenge already completed
      }
      
      // Mark challenge as completed
      await repository.markChallengeCompleted(challengeId);
      
      // Update engagement profile
      await _updateEngagementProfile(challenge, completedAt);
      
      // Record analytics
      await analytics.recordChallengeCompleted(
        challengeId: challengeId,
        challengeType: challenge.type,
        challengeTitle: challenge.title,
        completedAt: completedAt,
        timeToComplete: completedAt.difference(DateTime.now().subtract(const Duration(hours: 1))), // Approximate
      );
      
      return true;
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  Future<void> _updateEngagementProfile(DailyChallenge challenge, DateTime completedAt) async {
    try {
      final profile = await repository.getEngagementProfile();
      
      // Update challenge type stats
      final updatedChallengeStats = Map<String, int>.from(profile.challengeTypeStats);
      final challengeTypeKey = challenge.type.name;
      updatedChallengeStats[challengeTypeKey] = (updatedChallengeStats[challengeTypeKey] ?? 0) + 1;
      
      // Check if this is the first engagement today
      final today = DateTime.now();
      final isFirstEngagementToday = !_isSameDay(profile.lastEngagementDate, today);
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (isFirstEngagementToday) {
        // Check if this continues a streak
        final yesterday = today.subtract(const Duration(days: 1));
        final wasActiveYesterday = _isSameDay(profile.lastEngagementDate, yesterday);
        
        if (wasActiveYesterday || profile.currentStreak == 0) {
          // Continue or start streak
          newCurrentStreak = profile.currentStreak + 1;
        } else {
          // Streak was broken, start new one
          newCurrentStreak = 1;
        }
        
        // Update longest streak if necessary
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
          // Record streak milestone
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
      
      // Record daily engagement analytics
      await analytics.recordDailyEngagement(
        sessionDate: completedAt,
        challengeCompleted: true,
        bonusContentViewed: 0, // Will be updated separately
        currentStreak: newCurrentStreak,
      );
      
    } catch (e) {
      // Log error in production but don't rethrow to avoid blocking challenge completion
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}