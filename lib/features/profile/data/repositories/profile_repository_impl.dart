import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  // Initial user profile data - will be updated based on gameplay
  UserProfile _userProfile = UserProfile(
    id: 'user_001',
    name: 'Player',
    avatarUrl: '',
    totalScore: 2450,
    level: 5,
    gamesPlayed: 23,
    totalPlayTime: 3600, // 1 hour
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
    gameStats: {
      'memory_game': 850,
      'number_puzzle': 650,
    },
    currentStreak: 0,
    longestStreak: 0,
    totalChallengesCompleted: 0,
    totalBonusContentViewed: 0,
  );

  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first game',
      icon: Icons.play_arrow,
      type: AchievementType.firstGame,
      rarity: AchievementRarity.common,
      targetValue: 1,
      isUnlocked: true,
      progress: 1.0,
      unlockedAt: DateTime.now().subtract(const Duration(days: 25)),
      xpReward: 100,
    ),
    Achievement(
      id: 'memory_master',
      title: 'Memory Master',
      description: 'Score 500+ points in Memory Game',
      icon: Icons.psychology,
      type: AchievementType.scoreBasedMilestone,
      rarity: AchievementRarity.rare,
      targetValue: 500,
      isUnlocked: true,
      progress: 1.0,
      unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
      xpReward: 250,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete Memory Game in under 30 seconds',
      icon: Icons.flash_on,
      type: AchievementType.speedRun,
      rarity: AchievementRarity.epic,
      targetValue: 30,
      isUnlocked: false,
      progress: 0.6,
      xpReward: 500,
    ),
    Achievement(
      id: 'perfect_memory',
      title: 'Perfect Memory',
      description: 'Complete Memory Game without mistakes',
      icon: Icons.star,
      type: AchievementType.perfectGame,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      isUnlocked: false,
      progress: 0.0,
      xpReward: 750,
    ),
    Achievement(
      id: 'game_addict',
      title: 'Game Addict',
      description: 'Play 50 games',
      icon: Icons.games,
      type: AchievementType.gamesPlayedMilestone,
      rarity: AchievementRarity.rare,
      targetValue: 50,
      isUnlocked: false,
      progress: 0.46, // 23/50
      xpReward: 300,
    ),
    Achievement(
      id: 'high_scorer',
      title: 'High Scorer',
      description: 'Reach 5000 total points',
      icon: Icons.trending_up,
      type: AchievementType.scoreBasedMilestone,
      rarity: AchievementRarity.epic,
      targetValue: 5000,
      isUnlocked: false,
      progress: 0.49, // 2450/5000
      xpReward: 500,
    ),
    Achievement(
      id: 'dedication',
      title: 'Dedication',
      description: 'Play for 10 hours total',
      icon: Icons.access_time,
      type: AchievementType.timeBasedMilestone,
      rarity: AchievementRarity.rare,
      targetValue: 36000, // 10 hours in seconds
      isUnlocked: false,
      progress: 0.1, // 3600/36000
      xpReward: 400,
    ),
    Achievement(
      id: 'legend',
      title: 'Legend',
      description: 'Reach level 20',
      icon: Icons.diamond,
      type: AchievementType.mastery,
      rarity: AchievementRarity.legendary,
      targetValue: 20,
      isUnlocked: false,
      progress: 0.25, // 5/20
      xpReward: 1000,
    ),
  ];

  @override
  Future<UserProfile> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _userProfile;
  }

  @override
  Future<void> syncEngagementMetrics({
    required int currentStreak,
    required int longestStreak,
    required int totalChallengesCompleted,
    required int totalBonusContentViewed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _userProfile = _userProfile.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalChallengesCompleted: totalChallengesCompleted,
      totalBonusContentViewed: totalBonusContentViewed,
    );
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userProfile = profile;
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_achievements);
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        progress: 1.0,
        unlockedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateAchievementProgress(String achievementId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        progress: progress.clamp(0.0, 1.0),
      );
    }
  }

  @override
  Future<void> addGameResult({
    required String gameType,
    required int score,
    required int playTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Update user profile
    final newGameStats = Map<String, int>.from(_userProfile.gameStats);
    final currentBest = newGameStats[gameType] ?? 0;
    if (score > currentBest) {
      newGameStats[gameType] = score;
    }

    _userProfile = _userProfile.copyWith(
      totalScore: _userProfile.totalScore + score,
      level: ((_userProfile.totalScore + score) ~/ 1000) + 1,
      gamesPlayed: _userProfile.gamesPlayed + 1,
      totalPlayTime: _userProfile.totalPlayTime + playTime,
      lastPlayedAt: DateTime.now(),
      gameStats: newGameStats,
    );

    // Update achievement progress
    _updateAchievementProgressInternal();
  }

  void _updateAchievementProgressInternal() {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      double newProgress = 0.0;
      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.firstGame:
          newProgress = _userProfile.gamesPlayed >= 1 ? 1.0 : 0.0;
          shouldUnlock = _userProfile.gamesPlayed >= 1;
          break;
        case AchievementType.scoreBasedMilestone:
          if (achievement.id == 'high_scorer') {
            newProgress = (_userProfile.totalScore / achievement.targetValue).clamp(0.0, 1.0);
            shouldUnlock = _userProfile.totalScore >= achievement.targetValue;
          } else {
            // Game-specific score achievements
            final gameScore = _userProfile.gameStats['memory_game'] ?? 0;
            newProgress = (gameScore / achievement.targetValue).clamp(0.0, 1.0);
            shouldUnlock = gameScore >= achievement.targetValue;
          }
          break;
        case AchievementType.gamesPlayedMilestone:
          newProgress = (_userProfile.gamesPlayed / achievement.targetValue).clamp(0.0, 1.0);
          shouldUnlock = _userProfile.gamesPlayed >= achievement.targetValue;
          break;
        case AchievementType.timeBasedMilestone:
          newProgress = (_userProfile.totalPlayTime / achievement.targetValue).clamp(0.0, 1.0);
          shouldUnlock = _userProfile.totalPlayTime >= achievement.targetValue;
          break;
        case AchievementType.mastery:
          newProgress = (_userProfile.level / achievement.targetValue).clamp(0.0, 1.0);
          shouldUnlock = _userProfile.level >= achievement.targetValue;
          break;
        default:
          // Keep current progress for other types (perfectGame, speedRun, etc.)
          newProgress = achievement.progress;
      }

      _achievements[i] = achievement.copyWith(
        progress: newProgress,
        isUnlocked: shouldUnlock,
        unlockedAt: shouldUnlock ? DateTime.now() : null,
      );
    }
  }
}