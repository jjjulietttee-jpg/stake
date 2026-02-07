import '../entities/daily_challenge.dart';
import '../entities/daily_bonus_content.dart';
import '../entities/engagement_profile.dart';

abstract class EngagementRepository {
  Future<DailyChallenge?> getTodaysChallenge();
  
  Future<void> markChallengeCompleted(String challengeId);
  
  Future<List<DailyBonusContent>> getTodaysBonusContent();
  
  Future<void> markBonusContentViewed(String contentId);
  
  Future<EngagementProfile> getEngagementProfile();
  
  Future<void> updateEngagementProfile(EngagementProfile profile);
  
  Future<void> resetDailyData();
  
  Future<bool> shouldResetDaily();
  
  Future<DateTime?> getLastResetDate();
  
  Future<void> updateLastResetDate(DateTime date);
}