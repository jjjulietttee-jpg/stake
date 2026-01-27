import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AchievementType {
  firstGame,
  scoreBasedMilestone,
  gamesPlayedMilestone,
  timeBasedMilestone,
  perfectGame,
  speedRun,
  dedication,
  mastery,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final bool isUnlocked;
  final double progress;
  final DateTime? unlockedAt;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.isUnlocked,
    required this.progress,
    this.unlockedAt,
    required this.xpReward,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    bool? isUnlocked,
    double? progress,
    DateTime? unlockedAt,
    int? xpReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  double get progressPercentage => (progress * 100).clamp(0, 100);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        type,
        rarity,
        targetValue,
        isUnlocked,
        progress,
        unlockedAt,
        xpReward,
      ];
}