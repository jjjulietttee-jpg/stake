import 'package:equatable/equatable.dart';
import 'memory_card.dart';

enum GameStatus { initial, playing, paused, completed, gameOver }

class MemoryGameState extends Equatable {
  final List<MemoryCard> cards;
  final int moves;
  final int matches;
  final int score;
  final GameStatus status;
  final int? firstCardIndex;
  final int? secondCardIndex;
  final bool canFlip;
  final Duration elapsedTime;

  const MemoryGameState({
    this.cards = const [],
    this.moves = 0,
    this.matches = 0,
    this.score = 0,
    this.status = GameStatus.initial,
    this.firstCardIndex,
    this.secondCardIndex,
    this.canFlip = true,
    this.elapsedTime = Duration.zero,
  });

  MemoryGameState copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? matches,
    int? score,
    GameStatus? status,
    int? firstCardIndex,
    int? secondCardIndex,
    bool? canFlip,
    Duration? elapsedTime,
  }) {
    return MemoryGameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      score: score ?? this.score,
      status: status ?? this.status,
      firstCardIndex: firstCardIndex,
      secondCardIndex: secondCardIndex,
      canFlip: canFlip ?? this.canFlip,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }

  bool get isGameCompleted => matches * 2 == cards.length && cards.isNotEmpty;
  
  int get totalPairs => cards.length ~/ 2;

  @override
  List<Object?> get props => [
        cards,
        moves,
        matches,
        score,
        status,
        firstCardIndex,
        secondCardIndex,
        canFlip,
        elapsedTime,
      ];
}