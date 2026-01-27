import '../entities/user_profile.dart';
import '../entities/achievement.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Future<List<Achievement>> getAchievements();
  Future<void> unlockAchievement(String achievementId);
  Future<void> updateAchievementProgress(String achievementId, double progress);
  Future<void> addGameResult({
    required String gameType,
    required int score,
    required int playTime,
  });
}