import 'package:flutter/material.dart';
import '../entities/memory_card.dart';

abstract class MemoryGameRepository {
  List<MemoryCard> generateCards({int pairs = 8});
  List<IconData> getAvailableIcons();
  int calculateScore({
    required int matches,
    required int moves,
    required Duration elapsedTime,
  });
}