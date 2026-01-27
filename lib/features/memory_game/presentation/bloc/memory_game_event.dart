import 'package:equatable/equatable.dart';

abstract class MemoryGameEvent extends Equatable {
  const MemoryGameEvent();

  @override
  List<Object?> get props => [];
}

class StartGame extends MemoryGameEvent {
  final int pairs;

  const StartGame({this.pairs = 8});

  @override
  List<Object?> get props => [pairs];
}

class FlipCard extends MemoryGameEvent {
  final int cardIndex;

  const FlipCard(this.cardIndex);

  @override
  List<Object?> get props => [cardIndex];
}

class CheckMatch extends MemoryGameEvent {
  const CheckMatch();
}

class CheckMatchWithIndices extends MemoryGameEvent {
  final int firstCardIndex;
  final int secondCardIndex;

  const CheckMatchWithIndices(this.firstCardIndex, this.secondCardIndex);

  @override
  List<Object?> get props => [firstCardIndex, secondCardIndex];
}

class ResetGame extends MemoryGameEvent {
  const ResetGame();
}

class PauseGame extends MemoryGameEvent {
  const PauseGame();
}

class ResumeGame extends MemoryGameEvent {
  const ResumeGame();
}

class UpdateTimer extends MemoryGameEvent {
  final Duration elapsedTime;

  const UpdateTimer(this.elapsedTime);

  @override
  List<Object?> get props => [elapsedTime];
}