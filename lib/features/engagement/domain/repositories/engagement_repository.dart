import '../entities/daily_challenge.dart';
import '../entities/daily_bonus_content.dart';
import '../entities/engagement_profile.dart';

abstract class EngagementRepository {
  /// Get today's daily challenge
  Future<DailyChallenge?> getTodaysChallenge();
  
  /// Mark a challenge as completed
  Future<void> markChallengeCompleted(String challengeId);
  
  /// Get today's bonus content
  Future<List<DailyBonusContent>> getTodaysBonusContent();
  
  /// Mark bonus content as viewed
  Future<void> markBonusContentViewed(String contentId);
  
  /// Get user's engagement profile
  Future<EngagementProfile> getEngagementProfile();
  
  /// Update user's engagement profile
  Future<void> updateEngagementProfile(EngagementProfile profile);
  
  /// Reset daily data (called at day transition)
  Future<void> resetDailyData();
  
  /// Check if daily reset is needed
  Future<bool> shouldResetDaily();
  
  /// Get last reset date
  Future<DateTime?> getLastResetDate();
  
  /// Update last reset date
  Future<void> updateLastResetDate(DateTime date);
}