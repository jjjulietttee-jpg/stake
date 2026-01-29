import '../entities/engagement_profile.dart';
import '../repositories/engagement_repository.dart';
import '../services/engagement_analytics.dart';

class UpdateStreakUseCase {
  final EngagementRepository repository;
  final EngagementAnalytics analytics;

  UpdateStreakUseCase({
    required this.repository,
    required this.analytics,
  });

  Future<EngagementProfile> call({
    required DateTime engagementDate,
    bool forceUpdate = false,
  }) async {
    try {
      final profile = await repository.getEngagementProfile();
      
      // Check if this is the first engagement today
      final today = DateTime(engagementDate.year, engagementDate.month, engagementDate.day);
      final lastEngagement = DateTime(
        profile.lastEngagementDate.year,
        profile.lastEngagementDate.month,
        profile.lastEngagementDate.day,
      );
      
      // If already engaged today and not forcing update, return current profile
      if (!forceUpdate && _isSameDay(profile.lastEngagementDate, engagementDate)) {
        return profile;
      }
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (today.isAfter(lastEngagement)) {
        // This is a new day
        final yesterday = today.subtract(const Duration(days: 1));
        
        if (_isSameDay(lastEngagement, yesterday)) {
          // Consecutive day - continue streak
          newCurrentStreak = profile.currentStreak + 1;
        } else if (_isSameDay(lastEngagement, today.subtract(const Duration(days: 0)))) {
          // Same day - no change to streak
          newCurrentStreak = profile.currentStreak;
        } else {
          // Gap in engagement - start new streak
          newCurrentStreak = 1;
        }
        
        // Update longest streak if necessary
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
          // Record milestone achievement
          await analytics.recordStreakMilestone(
            streakLength: newCurrentStreak,
            achievedAt: engagementDate,
          );
        }
      }
      
      final updatedProfile = profile.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        lastEngagementDate: engagementDate,
      );
      
      await repository.updateEngagementProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  /// Calculate streak based on engagement history
  Future<int> calculateCurrentStreak() async {
    try {
      final profile = await repository.getEngagementProfile();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastEngagement = DateTime(
        profile.lastEngagementDate.year,
        profile.lastEngagementDate.month,
        profile.lastEngagementDate.day,
      );
      
      // If last engagement was today or yesterday, streak is current
      if (_isSameDay(lastEngagement, today) || 
          _isSameDay(lastEngagement, today.subtract(const Duration(days: 1)))) {
        return profile.currentStreak;
      }
      
      // Otherwise, streak is broken
      return 0;
    } catch (e) {
      // Log error in production
      return 0;
    }
  }

  /// Reset streak (used when user misses days)
  Future<EngagementProfile> resetStreak() async {
    try {
      final profile = await repository.getEngagementProfile();
      
      final updatedProfile = profile.copyWith(
        currentStreak: 0,
      );
      
      await repository.updateEngagementProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}