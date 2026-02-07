import '../entities/daily_challenge.dart';
import '../entities/daily_bonus_content.dart';
import '../entities/engagement_profile.dart';
import '../repositories/engagement_repository.dart';
import '../usecases/get_todays_challenge_usecase.dart';
import '../usecases/complete_challenge_usecase.dart';
import '../usecases/update_streak_usecase.dart';
import '../usecases/get_todays_bonus_content_usecase.dart';
import '../usecases/mark_bonus_viewed_usecase.dart';
import 'engagement_analytics.dart';

class EngagementService {
  final EngagementRepository repository;
  final GetTodaysChallengeUseCase getTodaysChallengeUseCase;
  final CompleteChallengeUseCase completeChallengeUseCase;
  final UpdateStreakUseCase updateStreakUseCase;
  final GetTodaysBonusContentUseCase getTodaysBonusContentUseCase;
  final MarkBonusViewedUseCase markBonusViewedUseCase;
  final EngagementAnalytics analytics;

  EngagementService({
    required this.repository,
    required this.getTodaysChallengeUseCase,
    required this.completeChallengeUseCase,
    required this.updateStreakUseCase,
    required this.getTodaysBonusContentUseCase,
    required this.markBonusViewedUseCase,
    required this.analytics,
  });


  Future<DailyChallenge?> getTodaysChallenge() async {
    return await getTodaysChallengeUseCase();
  }

  Future<bool> completeChallenge({
    required String challengeId,
    Map<String, dynamic>? gameData,
  }) async {
    final completedAt = DateTime.now();
    
    final success = await completeChallengeUseCase(
      challengeId: challengeId,
      completedAt: completedAt,
    );
    
    if (success) {
      await _awardChallengeAchievements(challengeId, gameData);
      
      await updateStreakUseCase(engagementDate: completedAt);
      
      await analytics.recordFeatureUsage(
        featureName: 'daily_challenge',
        action: 'completed',
        timestamp: completedAt,
        additionalData: {
          'challenge_id': challengeId,
          if (gameData != null) ...gameData,
        },
      );
    }
    
    return success;
  }

  Future<bool> canCompleteChallenge({
    required String challengeId,
    required Map<String, dynamic> gameData,
  }) async {
    try {
      final challenge = await getTodaysChallenge();
      if (challenge == null || challenge.id != challengeId || challenge.isCompleted) {
        return false;
      }
      
      return _checkChallengeCompletion(challenge, gameData);
    } catch (e) {
      return false;
    }
  }


  Future<List<DailyBonusContent>> getTodaysBonusContent() async {
    return await getTodaysBonusContentUseCase();
  }

  Future<List<DailyBonusContent>> getUnviewedBonusContent() async {
    return await getTodaysBonusContentUseCase.getUnviewedContent();
  }

  Future<bool> viewBonusContent(String contentId) async {
    final viewedAt = DateTime.now();
    
    final success = await markBonusViewedUseCase(
      contentId: contentId,
      viewedAt: viewedAt,
    );
    
    if (success) {
      await analytics.recordFeatureUsage(
        featureName: 'daily_bonus',
        action: 'viewed',
        timestamp: viewedAt,
        additionalData: {'content_id': contentId},
      );
    }
    
    return success;
  }


  Future<EngagementProfile> getEngagementProfile() async {
    return await repository.getEngagementProfile();
  }

  Future<EngagementProfile> updateStreak({DateTime? engagementDate}) async {
    return await updateStreakUseCase(
      engagementDate: engagementDate ?? DateTime.now(),
    );
  }

  Future<int> getCurrentStreak() async {
    return await updateStreakUseCase.calculateCurrentStreak();
  }


  Future<void> onGameCompleted({
    required String gameType,
    required int score,
    required Duration playTime,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final gameData = {
        'game_type': gameType,
        'score': score,
        'play_time_seconds': playTime.inSeconds,
        if (additionalData != null) ...additionalData,
      };
      
      final challenge = await getTodaysChallenge();
      if (challenge != null && !challenge.isCompleted) {
        final canComplete = await canCompleteChallenge(
          challengeId: challenge.id,
          gameData: gameData,
        );
        
        if (canComplete) {
          await completeChallenge(
            challengeId: challenge.id,
            gameData: gameData,
          );
        }
      }
      
      await updateStreak();
      
    } catch (e) {
    }
  }

  Future<Map<String, dynamic>> getEngagementSummary() async {
    try {
      final profile = await getEngagementProfile();
      final challenge = await getTodaysChallenge();
      final bonusContent = await getTodaysBonusContent();
      final unviewedContent = bonusContent.where((c) => !c.isViewed).length;
      
      return {
        'current_streak': profile.currentStreak,
        'longest_streak': profile.longestStreak,
        'total_challenges_completed': profile.totalChallengesCompleted,
        'total_bonus_content_viewed': profile.totalBonusContentViewed,
        'todays_challenge_completed': challenge?.isCompleted ?? false,
        'unviewed_bonus_content': unviewedContent,
        'challenge_title': challenge?.title,
        'challenge_description': challenge?.description,
      };
    } catch (e) {
      return {};
    }
  }


  bool _checkChallengeCompletion(DailyChallenge challenge, Map<String, dynamic> gameData) {
    switch (challenge.type) {
      case ChallengeType.playGames:
        return false;
        
      case ChallengeType.achieveScore:
        final targetScore = challenge.parameters['targetScore'] as int? ?? 0;
        final gameScore = gameData['score'] as int? ?? 0;
        return gameScore >= targetScore;
        
      case ChallengeType.playTime:
        return false;
        
      case ChallengeType.perfectGame:
        final mistakes = gameData['mistakes'] as int? ?? 1;
        return mistakes == 0;
        
      case ChallengeType.streak:
        return false;
    }
  }

  Future<void> _awardChallengeAchievements(String challengeId, Map<String, dynamic>? gameData) async {
    try {
      
      final profile = await getEngagementProfile();
      if (profile.currentStreak > 0 && profile.currentStreak % 7 == 0) {
      }
      
      if (profile.totalChallengesCompleted > 0 && profile.totalChallengesCompleted % 10 == 0) {
      }
      
    } catch (e) {
    }
  }
}