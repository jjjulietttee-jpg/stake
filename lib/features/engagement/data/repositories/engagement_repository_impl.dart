import '../../domain/entities/daily_challenge.dart';
import '../../domain/entities/daily_bonus_content.dart';
import '../../domain/entities/engagement_profile.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../datasources/engagement_local_data_source.dart';
import '../models/daily_challenge_model.dart';
import '../models/daily_bonus_content_model.dart';
import '../models/engagement_profile_model.dart';

class EngagementRepositoryImpl implements EngagementRepository {
  final EngagementLocalDataSource localDataSource;

  EngagementRepositoryImpl({required this.localDataSource});

  @override
  Future<DailyChallenge?> getTodaysChallenge() async {
    try {
      final challengeModel = await localDataSource.getTodaysChallenge();
      return challengeModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markChallengeCompleted(String challengeId) async {
    try {
      await localDataSource.markChallengeCompleted(challengeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DailyBonusContent>> getTodaysBonusContent() async {
    try {
      final contentModels = await localDataSource.getTodaysBonusContent();
      return contentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markBonusContentViewed(String contentId) async {
    try {
      await localDataSource.markBonusContentViewed(contentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EngagementProfile> getEngagementProfile() async {
    try {
      final profileModel = await localDataSource.getEngagementProfile();
      return profileModel.toEntity();
    } catch (e) {
      return EngagementProfile.empty();
    }
  }

  @override
  Future<void> updateEngagementProfile(EngagementProfile profile) async {
    try {
      final profileModel = EngagementProfileModel.fromEntity(profile);
      await localDataSource.saveEngagementProfile(profileModel);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetDailyData() async {
    try {
      await localDataSource.clearDailyData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> shouldResetDaily() async {
    try {
      final lastResetDate = await localDataSource.getLastResetDate();
      if (lastResetDate == null) return true;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastReset = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);
      
      return today.isAfter(lastReset);
    } catch (e) {
      return true;
    }
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    try {
      return await localDataSource.getLastResetDate();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateLastResetDate(DateTime date) async {
    try {
      await localDataSource.saveLastResetDate(date);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveTodaysChallenge(DailyChallenge challenge) async {
    try {
      final challengeModel = DailyChallengeModel.fromEntity(challenge);
      await localDataSource.saveTodaysChallenge(challengeModel);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveTodaysBonusContent(List<DailyBonusContent> content) async {
    try {
      final contentModels = content
          .map((item) => DailyBonusContentModel.fromEntity(item))
          .toList();
      await localDataSource.saveTodaysBonusContent(contentModels);
    } catch (e) {
      rethrow;
    }
  }
}