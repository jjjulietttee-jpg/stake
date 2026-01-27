import '../entities/memory_card.dart';
import '../repositories/memory_game_repository.dart';

class StartGameUseCase {
  final MemoryGameRepository repository;

  StartGameUseCase(this.repository);

  List<MemoryCard> call({int pairs = 8}) {
    return repository.generateCards(pairs: pairs);
  }
}