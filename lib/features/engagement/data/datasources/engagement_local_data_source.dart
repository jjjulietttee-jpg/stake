import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stake/features/engagement/domain/entities/engagement_profile.dart';
import '../models/daily_challenge_model.dart';
import '../models/daily_bonus_content_model.dart';
import '../models/engagement_profile_model.dart';

abstract class EngagementLocalDataSource {
  Future<DailyChallengeModel?> getTodaysChallenge();
  Future<void> saveTodaysChallenge(DailyChallengeModel challenge);
  Future<void> markChallengeCompleted(String challengeId);

  Future<List<DailyBonusContentModel>> getTodaysBonusContent();
  Future<void> saveTodaysBonusContent(List<DailyBonusContentModel> content);
  Future<void> markBonusContentViewed(String contentId);

  Future<EngagementProfileModel> getEngagementProfile();
  Future<void> saveEngagementProfile(EngagementProfileModel profile);

  Future<DateTime?> getLastResetDate();
  Future<void> saveLastResetDate(DateTime date);

  Future<void> clearDailyData();
}

class EngagementLocalDataSourceImpl implements EngagementLocalDataSource {
  final SharedPreferences sharedPreferences;

  EngagementLocalDataSourceImpl({required this.sharedPreferences});

  static const String _dailyChallengeKey = 'daily_challenge';
  static const String _dailyBonusContentKey = 'daily_bonus_content';
  static const String _engagementProfileKey = 'engagement_profile';
  static const String _lastResetDateKey = 'last_reset_date';

  @override
  Future<DailyChallengeModel?> getTodaysChallenge() async {
    try {
      final challengeJson = sharedPreferences.getString(_dailyChallengeKey);
      if (challengeJson == null) return null;

      final challengeMap = json.decode(challengeJson) as Map<String, dynamic>;
      return DailyChallengeModel.fromJson(challengeMap);
    } catch (e) {
      // If there's an error parsing, return null to trigger regeneration
      return null;
    }
  }

  @override
  Future<void> saveTodaysChallenge(DailyChallengeModel challenge) async {
    final challengeJson = json.encode(challenge.toJson());
    await sharedPreferences.setString(_dailyChallengeKey, challengeJson);
  }

  @override
  Future<void> markChallengeCompleted(String challengeId) async {
    final challenge = await getTodaysChallenge();
    if (challenge != null && challenge.id == challengeId) {
      final completedChallenge = DailyChallengeModel(
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        type: challenge.type,
        parameters: challenge.parameters,
        date: challenge.date,
        isCompleted: true,
        rewards: challenge.rewards,
      );
      await saveTodaysChallenge(completedChallenge);
    }
  }

  @override
  Future<List<DailyBonusContentModel>> getTodaysBonusContent() async {
    try {
      final contentJson = sharedPreferences.getString(_dailyBonusContentKey);
      if (contentJson == null) return [];

      final contentList = json.decode(contentJson) as List;
      return contentList
          .map(
            (item) =>
                DailyBonusContentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list to trigger regeneration
      return [];
    }
  }

  @override
  Future<void> saveTodaysBonusContent(
    List<DailyBonusContentModel> content,
  ) async {
    final contentJson = json.encode(
      content.map((item) => item.toJson()).toList(),
    );
    await sharedPreferences.setString(_dailyBonusContentKey, contentJson);
  }

  @override
  Future<void> markBonusContentViewed(String contentId) async {
    final contentList = await getTodaysBonusContent();
    final updatedList = contentList.map((content) {
      if (content.id == contentId) {
        return DailyBonusContentModel(
          id: content.id,
          title: content.title,
          content: content.content,
          type: content.type,
          date: content.date,
          isViewed: true,
          imageUrl: content.imageUrl,
          metadata: content.metadata,
        );
      }
      return content;
    }).toList();

    await saveTodaysBonusContent(updatedList);
  }

  @override
  Future<EngagementProfileModel> getEngagementProfile() async {
    try {
      final profileJson = sharedPreferences.getString(_engagementProfileKey);
      if (profileJson == null) {
        // Return empty profile if none exists
        return EngagementProfileModel.fromEntity(EngagementProfile.empty());
      }

      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      return EngagementProfileModel.fromJson(profileMap);
    } catch (e) {
      // If there's an error parsing, return empty profile
      return EngagementProfileModel.fromEntity(EngagementProfile.empty());
    }
  }

  @override
  Future<void> saveEngagementProfile(EngagementProfileModel profile) async {
    final profileJson = json.encode(profile.toJson());
    await sharedPreferences.setString(_engagementProfileKey, profileJson);
  }

  @override
  Future<DateTime?> getLastResetDate() async {
    final dateString = sharedPreferences.getString(_lastResetDateKey);
    if (dateString == null) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    await sharedPreferences.setString(
      _lastResetDateKey,
      date.toIso8601String(),
    );
  }

  @override
  Future<void> clearDailyData() async {
    await Future.wait([
      sharedPreferences.remove(_dailyChallengeKey),
      sharedPreferences.remove(_dailyBonusContentKey),
    ]);
  }
}
