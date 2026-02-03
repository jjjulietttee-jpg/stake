import 'dart:math';
import '../entities/daily_challenge.dart';

class ChallengeGenerator {
  final Random _random = Random();

  /// Generate a daily challenge for the given date
  /// Ensures challenges are different each day by using date as seed
  DailyChallenge generateChallenge(DateTime date) {
    // Use date as seed to ensure same challenge for same day
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    
    final challengeTypes = ChallengeType.values;
    final selectedType = challengeTypes[random.nextInt(challengeTypes.length)];
    
    return _generateChallengeForType(selectedType, date, random);
  }

  DailyChallenge _generateChallengeForType(
    ChallengeType type,
    DateTime date,
    Random random,
  ) {
    final challengeId = 'challenge_${date.year}_${date.month}_${date.day}';
    
    switch (type) {
      case ChallengeType.playGames:
        return _generatePlayGamesChallenge(challengeId, date, random);
      case ChallengeType.achieveScore:
        return _generateAchieveScoreChallenge(challengeId, date, random);
      case ChallengeType.playTime:
        return _generatePlayTimeChallenge(challengeId, date, random);
      case ChallengeType.perfectGame:
        return _generatePerfectGameChallenge(challengeId, date, random);
      case ChallengeType.streak:
        return _generateStreakChallenge(challengeId, date, random);
    }
  }

  DailyChallenge _generatePlayGamesChallenge(
    String id,
    DateTime date,
    Random random,
  ) {
    final gameCount = 2 + random.nextInt(4); // 2-5 games
    final points = gameCount * 50; // 50 points per game
    
    return DailyChallenge(
      id: id,
      title: 'Game Marathon',
      description: 'Play $gameCount games today',
      type: ChallengeType.playGames,
      parameters: {'targetGames': gameCount},
      date: date,
      isCompleted: false,
      rewards: [
        Reward(
          id: '${id}_reward',
          type: RewardType.points,
          title: 'Bonus Points',
          description: 'Earn $points bonus points',
          value: points,
        ),
      ],
    );
  }

  DailyChallenge _generateAchieveScoreChallenge(
    String id,
    DateTime date,
    Random random,
  ) {
    final baseScores = [300, 400, 500, 600, 750];
    final targetScore = baseScores[random.nextInt(baseScores.length)];
    final points = (targetScore * 0.5).round();
    
    return DailyChallenge(
      id: id,
      title: 'High Score Hunter',
      description: 'Score $targetScore points in any game',
      type: ChallengeType.achieveScore,
      parameters: {'targetScore': targetScore},
      date: date,
      isCompleted: false,
      rewards: [
        Reward(
          id: '${id}_reward',
          type: RewardType.points,
          title: 'Score Bonus',
          description: 'Earn $points bonus points',
          value: points,
        ),
      ],
    );
  }

  DailyChallenge _generatePlayTimeChallenge(
    String id,
    DateTime date,
    Random random,
  ) {
    final timeOptions = [5, 10, 15, 20]; // minutes
    final targetMinutes = timeOptions[random.nextInt(timeOptions.length)];
    final points = targetMinutes * 10;
    
    return DailyChallenge(
      id: id,
      title: 'Time Investment',
      description: 'Play for $targetMinutes minutes total',
      type: ChallengeType.playTime,
      parameters: {'targetMinutes': targetMinutes},
      date: date,
      isCompleted: false,
      rewards: [
        Reward(
          id: '${id}_reward',
          type: RewardType.points,
          title: 'Time Bonus',
          description: 'Earn $points bonus points',
          value: points,
        ),
      ],
    );
  }

  DailyChallenge _generatePerfectGameChallenge(
    String id,
    DateTime date,
    Random random,
  ) {
    final trainingModes = ['Memory Card Exercise', 'Puzzle Exercise'];
    final selectedMode = trainingModes[random.nextInt(trainingModes.length)];
    
    return DailyChallenge(
      id: id,
      title: 'Perfection',
      description: 'Complete $selectedMode without mistakes',
      type: ChallengeType.perfectGame,
      parameters: {'trainingMode': selectedMode},
      date: date,
      isCompleted: false,
      rewards: [
        Reward(
          id: '${id}_reward',
          type: RewardType.badge,
          title: 'Perfect Player',
          description: 'Badge for flawless performance',
          value: 1,
        ),
        Reward(
          id: '${id}_points_reward',
          type: RewardType.points,
          title: 'Perfection Bonus',
          description: 'Earn 500 bonus points',
          value: 500,
        ),
      ],
    );
  }

  DailyChallenge _generateStreakChallenge(
    String id,
    DateTime date,
    Random random,
  ) {
    final streakDays = 2 + random.nextInt(3); // 2-4 days
    final points = streakDays * 100;
    
    return DailyChallenge(
      id: id,
      title: 'Streak Master',
      description: 'Maintain a $streakDays-day playing streak',
      type: ChallengeType.streak,
      parameters: {'targetStreak': streakDays},
      date: date,
      isCompleted: false,
      rewards: [
        Reward(
          id: '${id}_reward',
          type: RewardType.streak,
          title: 'Streak Bonus',
          description: 'Streak multiplier bonus',
          value: streakDays,
        ),
        Reward(
          id: '${id}_points_reward',
          type: RewardType.points,
          title: 'Consistency Bonus',
          description: 'Earn $points bonus points',
          value: points,
        ),
      ],
    );
  }

  /// Get fallback challenges for when generation fails
  List<DailyChallenge> getFallbackChallenges(DateTime date) {
    final challengeId = 'fallback_${date.year}_${date.month}_${date.day}';
    
    return [
      DailyChallenge(
        id: challengeId,
        title: 'Daily Player',
        description: 'Play 2 games today',
        type: ChallengeType.playGames,
        parameters: {'targetGames': 2},
        date: date,
        isCompleted: false,
        rewards: [
          Reward(
            id: '${challengeId}_reward',
            type: RewardType.points,
            title: 'Daily Bonus',
            description: 'Earn 100 bonus points',
            value: 100,
          ),
        ],
      ),
    ];
  }
}