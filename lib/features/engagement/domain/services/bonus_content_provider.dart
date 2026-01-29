import 'dart:math';
import '../entities/daily_bonus_content.dart';

class BonusContentProvider {
  final Random _random = Random();

  /// Generate daily bonus content for the given date
  /// Uses date as seed to ensure same content for same day
  List<DailyBonusContent> generateDailyContent(DateTime date) {
    // Use date as seed to ensure same content for same day
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    
    // Generate 2-3 pieces of content per day
    final contentCount = 2 + random.nextInt(2);
    final content = <DailyBonusContent>[];
    
    // Ensure variety by selecting different types
    final availableTypes = List<ContentType>.from(ContentType.values);
    availableTypes.shuffle(random);
    
    for (int i = 0; i < contentCount && i < availableTypes.length; i++) {
      final contentType = availableTypes[i];
      final contentItem = _generateContentForType(contentType, date, random, i);
      content.add(contentItem);
    }
    
    return content;
  }

  DailyBonusContent _generateContentForType(
    ContentType type,
    DateTime date,
    Random random,
    int index,
  ) {
    final contentId = 'content_${date.year}_${date.month}_${date.day}_$index';
    
    switch (type) {
      case ContentType.gameTip:
        return _generateGameTip(contentId, date, random);
      case ContentType.funFact:
        return _generateFunFact(contentId, date, random);
      case ContentType.achievement:
        return _generateAchievementSpotlight(contentId, date, random);
      case ContentType.milestone:
        return _generateMilestone(contentId, date, random);
    }
  }

  DailyBonusContent _generateGameTip(
    String id,
    DateTime date,
    Random random,
  ) {
    final tips = [
      {
        'title': 'Memory Game Mastery',
        'content': 'Focus on creating mental patterns when memorizing card positions. Group cards by color or position to improve your recall speed.',
      },
      {
        'title': 'Speed Strategy',
        'content': 'Start with corner and edge cards first - they\'re easier to remember due to their unique positions on the board.',
      },
      {
        'title': 'Concentration Technique',
        'content': 'Take a moment to scan the entire board before making your first move. This initial overview helps build a mental map.',
      },
      {
        'title': 'Pattern Recognition',
        'content': 'Look for visual patterns in card arrangements. Similar colors or shapes near each other are easier to remember.',
      },
      {
        'title': 'Timing is Key',
        'content': 'Don\'t rush! Taking an extra second to think can prevent costly mistakes and improve your overall score.',
      },
      {
        'title': 'Practice Makes Perfect',
        'content': 'Regular short sessions are more effective than long gaming marathons. Your brain retains patterns better with consistent practice.',
      },
    ];
    
    final selectedTip = tips[random.nextInt(tips.length)];
    
    return DailyBonusContent(
      id: id,
      title: selectedTip['title']!,
      content: selectedTip['content']!,
      type: ContentType.gameTip,
      date: date,
      isViewed: false,
    );
  }

  DailyBonusContent _generateFunFact(
    String id,
    DateTime date,
    Random random,
  ) {
    final facts = [
      {
        'title': 'Memory Champion',
        'content': 'The world record for memorizing a deck of cards is just 12.74 seconds! Memory athletes use special techniques to achieve these incredible feats.',
      },
      {
        'title': 'Brain Training',
        'content': 'Playing memory games for just 15 minutes a day can improve your working memory and cognitive flexibility within weeks.',
      },
      {
        'title': 'Ancient Origins',
        'content': 'Memory games date back to ancient Greece, where scholars used memory palaces to remember vast amounts of information.',
      },
      {
        'title': 'Neuroplasticity',
        'content': 'Your brain creates new neural pathways every time you play memory games, literally rewiring itself to become more efficient.',
      },
      {
        'title': 'Sleep Connection',
        'content': 'Playing memory games before bed can improve memory consolidation during sleep, helping you remember things better the next day.',
      },
      {
        'title': 'Age is Just a Number',
        'content': 'Studies show that people in their 80s can improve their memory performance by 40% through regular brain training games.',
      },
    ];
    
    final selectedFact = facts[random.nextInt(facts.length)];
    
    return DailyBonusContent(
      id: id,
      title: selectedFact['title']!,
      content: selectedFact['content']!,
      type: ContentType.funFact,
      date: date,
      isViewed: false,
    );
  }

  DailyBonusContent _generateAchievementSpotlight(
    String id,
    DateTime date,
    Random random,
  ) {
    final achievements = [
      {
        'title': 'Speed Demon Challenge',
        'content': 'Complete a Memory Game in under 30 seconds to unlock the Speed Demon achievement. Focus on quick pattern recognition!',
      },
      {
        'title': 'Perfect Memory Goal',
        'content': 'Aim for the Perfect Memory achievement by completing a game without any mistakes. Take your time and trust your instincts.',
      },
      {
        'title': 'High Scorer Target',
        'content': 'Work towards the High Scorer achievement by reaching 5000 total points. Every game counts towards this milestone!',
      },
      {
        'title': 'Dedication Milestone',
        'content': 'The Dedication achievement awaits those who play for 10 hours total. Consistency is key to reaching this goal.',
      },
      {
        'title': 'Game Addict Badge',
        'content': 'Play 50 games to earn the Game Addict achievement. You\'re already making great progress - keep it up!',
      },
    ];
    
    final selectedAchievement = achievements[random.nextInt(achievements.length)];
    
    return DailyBonusContent(
      id: id,
      title: selectedAchievement['title']!,
      content: selectedAchievement['content']!,
      type: ContentType.achievement,
      date: date,
      isViewed: false,
    );
  }

  DailyBonusContent _generateMilestone(
    String id,
    DateTime date,
    Random random,
  ) {
    final milestones = [
      {
        'title': 'Welcome to the Journey',
        'content': 'Every expert was once a beginner. Your gaming journey starts with a single game - make it count!',
      },
      {
        'title': 'Building Momentum',
        'content': 'Consistency beats intensity. Playing a little each day will yield better results than occasional long sessions.',
      },
      {
        'title': 'Progress Celebration',
        'content': 'Take a moment to appreciate how far you\'ve come. Every game played is a step towards mastery.',
      },
      {
        'title': 'Skill Development',
        'content': 'Your memory skills are improving with each game. Trust the process and enjoy the journey of growth.',
      },
      {
        'title': 'Community Spirit',
        'content': 'You\'re part of a community of players all working to improve their cognitive abilities. Keep pushing forward!',
      },
    ];
    
    final selectedMilestone = milestones[random.nextInt(milestones.length)];
    
    return DailyBonusContent(
      id: id,
      title: selectedMilestone['title']!,
      content: selectedMilestone['content']!,
      type: ContentType.milestone,
      date: date,
      isViewed: false,
    );
  }

  /// Get fallback content when generation fails
  List<DailyBonusContent> getFallbackContent(DateTime date) {
    final contentId = 'fallback_${date.year}_${date.month}_${date.day}';
    
    return [
      DailyBonusContent(
        id: contentId,
        title: 'Daily Motivation',
        content: 'Welcome back! Every game you play helps improve your memory and cognitive abilities. Keep up the great work!',
        type: ContentType.milestone,
        date: date,
        isViewed: false,
      ),
    ];
  }

  /// Get content rotation index to ensure variety over time
  int _getRotationIndex(DateTime date, int totalItems) {
    final daysSinceEpoch = date.difference(DateTime(2024, 1, 1)).inDays;
    return daysSinceEpoch % totalItems;
  }
}