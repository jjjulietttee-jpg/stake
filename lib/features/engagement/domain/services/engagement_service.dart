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

/// Main service that coordinates all engagement features
/// Integrates with existing profile and achievement systems
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

  // Challenge-related methods

  /// Get today's daily challenge
  Future<DailyChallenge?> getTodaysChallenge() async {
    return await getTodaysChallengeUseCase();
  }

  /// Complete a daily challenge and award rewards
  Future<bool> completeChallenge({
    required String challengeId,
    Map<String, dynamic>? gameData,
  }) async {
    final completedAt = DateTime.now();
    
    // Complete the challenge
    final success = await completeChallengeUseCase(
      challengeId: challengeId,
      completedAt: completedAt,
    );
    
    if (success) {
      // Award achievements if applicable
      await _awardChallengeAchievements(challengeId, gameData);
      
      // Update streak
      await updateStreakUseCase(engagementDate: completedAt);
      
      // Record feature usage
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

  /// Check if challenge can be completed based on game data
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

  // Bonus content-related methods

  /// Get today's bonus content
  Future<List<DailyBonusContent>> getTodaysBonusContent() async {
    return await getTodaysBonusContentUseCase();
  }

  /// Get only unviewed bonus content
  Future<List<DailyBonusContent>> getUnviewedBonusContent() async {
    return await getTodaysBonusContentUseCase.getUnviewedContent();
  }

  /// Mark bonus content as viewed
  Future<bool> viewBonusContent(String contentId) async {
    final viewedAt = DateTime.now();
    
    final success = await markBonusViewedUseCase(
      contentId: contentId,
      viewedAt: viewedAt,
    );
    
    if (success) {
      // Record feature usage
      await analytics.recordFeatureUsage(
        featureName: 'daily_bonus',
        action: 'viewed',
        timestamp: viewedAt,
        additionalData: {'content_id': contentId},
      );
    }
    
    return success;
  }

  // Profile and streak methods

  /// Get user's engagement profile
  Future<EngagementProfile> getEngagementProfile() async {
    return await repository.getEngagementProfile();
  }

  /// Update engagement streak
  Future<EngagementProfile> updateStreak({DateTime? engagementDate}) async {
    return await updateStreakUseCase(
      engagementDate: engagementDate ?? DateTime.now(),
    );
  }

  /// Get current streak length
  Future<int> getCurrentStreak() async {
    return await updateStreakUseCase.calculateCurrentStreak();
  }

  // Integration with existing systems

  /// Called when user completes any game (integration point)
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
      
      // Check if this completes today's challenge
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
      
      // Update engagement metrics
      await updateStreak();
      
    } catch (e) {
      // Log error but don't throw to avoid breaking game completion
    }
  }

  /// Get engagement summary for display
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

  // Private helper methods

  bool _checkChallengeCompletion(DailyChallenge challenge, Map<String, dynamic> gameData) {
    switch (challenge.type) {
      case ChallengeType.playGames:
        // This would be tracked separately, not from single game completion
        return false;
        
      case ChallengeType.achieveScore:
        final targetScore = challenge.parameters['targetScore'] as int? ?? 0;
        final gameScore = gameData['score'] as int? ?? 0;
        return gameScore >= targetScore;
        
      case ChallengeType.playTime:
        // This would be tracked separately across multiple games
        return false;
        
      case ChallengeType.perfectGame:
        final mistakes = gameData['mistakes'] as int? ?? 1;
        return mistakes == 0;
        
      case ChallengeType.streak:
        // This is handled by streak tracking, not individual games
        return false;
    }
  }

  Future<void> _awardChallengeAchievements(String challengeId, Map<String, dynamic>? gameData) async {
    try {
      // Integration point with existing achievement system
      // This would call the existing achievement service
      
      // Example: Award streak-based achievements
      final profile = await getEngagementProfile();
      if (profile.currentStreak > 0 && profile.currentStreak % 7 == 0) {
        // Award weekly streak achievement
        // await achievementService.unlockAchievement('weekly_streak_${profile.currentStreak ~/ 7}');
      }
      
      // Example: Award challenge completion achievements
      if (profile.totalChallengesCompleted > 0 && profile.totalChallengesCompleted % 10 == 0) {
        // Award challenge milestone achievement
        // await achievementService.unlockAchievement('challenge_milestone_${profile.totalChallengesCompleted ~/ 10}');
      }
      
    } catch (e) {
      // Log error but don't throw to avoid blocking challenge completion
    }
  }
}