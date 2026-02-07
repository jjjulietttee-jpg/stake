import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/memory_card.dart';
import '../../domain/repositories/memory_game_repository.dart';

class MemoryGameRepositoryImpl implements MemoryGameRepository {
  final List<IconData> _availableIcons = [
    Icons.star,
    Icons.favorite,
    Icons.diamond,
    Icons.flash_on,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.cake,
    Icons.pets,
    Icons.local_florist,
    Icons.emoji_events,
    Icons.rocket_launch,
    Icons.palette,
    Icons.camera_alt,
    Icons.headphones,
    Icons.beach_access,
    Icons.flight,
  ];

  @override
  List<MemoryCard> generateCards({int pairs = 8}) {
    if (pairs > _availableIcons.length) {
      pairs = _availableIcons.length;
    }

    final selectedIcons = _availableIcons.take(pairs).toList();
    final gameIcons = [...selectedIcons, ...selectedIcons]; // Create pairs
    gameIcons.shuffle(Random());

    return gameIcons
        .asMap()
        .entries
        .map((entry) => MemoryCard(
              id: entry.key,
              icon: entry.value,
            ))
        .toList();
  }

  @override
  List<IconData> getAvailableIcons() {
    return List.from(_availableIcons);
  }

  @override
  int calculateScore({
    required int matches,
    required int moves,
    required Duration elapsedTime,
  }) {
    int baseScore = matches * 100;
    int movePenalty = moves * 5;
    int timeBonus = 0;
    if (elapsedTime.inSeconds < 60) {
      timeBonus = (60 - elapsedTime.inSeconds) * 2;
    }
    int finalScore = baseScore - movePenalty + timeBonus;
    
    return finalScore > 0 ? finalScore : 0;
  }
}