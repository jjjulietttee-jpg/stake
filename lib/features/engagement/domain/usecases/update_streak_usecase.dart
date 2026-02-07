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
      
      final today = DateTime(engagementDate.year, engagementDate.month, engagementDate.day);
      final lastEngagement = DateTime(
        profile.lastEngagementDate.year,
        profile.lastEngagementDate.month,
        profile.lastEngagementDate.day,
      );
      
      if (!forceUpdate && _isSameDay(profile.lastEngagementDate, engagementDate)) {
        return profile;
      }
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (today.isAfter(lastEngagement)) {
        final yesterday = today.subtract(const Duration(days: 1));
        
        if (_isSameDay(lastEngagement, yesterday)) {
          newCurrentStreak = profile.currentStreak + 1;
        } else if (_isSameDay(lastEngagement, today.subtract(const Duration(days: 0)))) {
          newCurrentStreak = profile.currentStreak;
        } else {
          newCurrentStreak = 1;
        }
        
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
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
      rethrow;
    }
  }

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
      
      if (_isSameDay(lastEngagement, today) || 
          _isSameDay(lastEngagement, today.subtract(const Duration(days: 1)))) {
        return profile.currentStreak;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<EngagementProfile> resetStreak() async {
    try {
      final profile = await repository.getEngagementProfile();
      
      final updatedProfile = profile.copyWith(
        currentStreak: 0,
      );
      
      await repository.updateEngagementProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e) {
      rethrow;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}