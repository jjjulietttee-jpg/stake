import '../repositories/memory_game_repository.dart';

class CalculateScoreUseCase {
  final MemoryGameRepository repository;

  CalculateScoreUseCase(this.repository);

  int call({
    required int matches,
    required int moves,
    required Duration elapsedTime,
  }) {
    return repository.calculateScore(
      matches: matches,
      moves: moves,
      elapsedTime: elapsedTime,
    );
  }
}