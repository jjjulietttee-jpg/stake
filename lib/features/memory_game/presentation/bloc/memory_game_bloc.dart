import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/memory_card.dart';
import '../../domain/usecases/start_game_usecase.dart';
import '../../domain/usecases/calculate_score_usecase.dart';
import 'memory_game_event.dart';

class MemoryGameBloc extends Bloc<MemoryGameEvent, MemoryGameState> {
  final StartGameUseCase startGameUseCase;
  final CalculateScoreUseCase calculateScoreUseCase;
  
  Timer? _gameTimer;
  DateTime? _gameStartTime;

  MemoryGameBloc({
    required this.startGameUseCase,
    required this.calculateScoreUseCase,
  }) : super(const MemoryGameState()) {
    on<StartGame>(_onStartGame);
    on<FlipCard>(_onFlipCard);
    on<CheckMatch>(_onCheckMatch);
    on<CheckMatchWithIndices>(_onCheckMatchWithIndices);
    on<ResetGame>(_onResetGame);
    on<PauseGame>(_onPauseGame);
    on<ResumeGame>(_onResumeGame);
    on<UpdateTimer>(_onUpdateTimer);
  }

  void _onStartGame(StartGame event, Emitter<MemoryGameState> emit) {
    final cards = startGameUseCase(pairs: event.pairs);
    _gameStartTime = DateTime.now();
    _startTimer();
    
    emit(state.copyWith(
      cards: cards,
      moves: 0,
      matches: 0,
      score: 0,
      status: GameStatus.playing,
      firstCardIndex: null,
      secondCardIndex: null,
      canFlip: true,
      elapsedTime: Duration.zero,
    ));
  }

  void _onFlipCard(FlipCard event, Emitter<MemoryGameState> emit) {
    if (!state.canFlip || 
        state.cards[event.cardIndex].isFlipped || 
        state.cards[event.cardIndex].isMatched) {
      return;
    }
    final openCards = <int>[];
    for (int i = 0; i < state.cards.length; i++) {
      if (state.cards[i].isFlipped && !state.cards[i].isMatched) {
        openCards.add(i);
      }
    }
    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[event.cardIndex] = updatedCards[event.cardIndex].copyWith(isFlipped: true);

    if (openCards.isEmpty) {
      emit(state.copyWith(
        cards: updatedCards,
        firstCardIndex: event.cardIndex,
        secondCardIndex: null,
      ));
    } else if (openCards.length == 1 && openCards[0] != event.cardIndex) {
      final firstCardIndex = openCards[0];
      final secondCardIndex = event.cardIndex;
      emit(state.copyWith(
        cards: updatedCards,
        firstCardIndex: firstCardIndex,
        secondCardIndex: secondCardIndex,
        moves: state.moves + 1,
        canFlip: false,
      ));
      Timer(const Duration(milliseconds: 1000), () {
        add(CheckMatchWithIndices(firstCardIndex, secondCardIndex));
      });
    }
  }

  void _onCheckMatchWithIndices(CheckMatchWithIndices event, Emitter<MemoryGameState> emit) {
    if (event.firstCardIndex >= state.cards.length || event.secondCardIndex >= state.cards.length) {
      return;
    }

    final firstCard = state.cards[event.firstCardIndex];
    final secondCard = state.cards[event.secondCardIndex];
    final updatedCards = List<MemoryCard>.from(state.cards);
    if (firstCard.icon == secondCard.icon) {
      updatedCards[event.firstCardIndex] = firstCard.copyWith(isMatched: true, isFlipped: true);
      updatedCards[event.secondCardIndex] = secondCard.copyWith(isMatched: true, isFlipped: true);
      
      final newMatches = state.matches + 1;
      final newScore = calculateScoreUseCase(
        matches: newMatches,
        moves: state.moves,
        elapsedTime: state.elapsedTime,
      );

      final newState = state.copyWith(
        cards: updatedCards,
        matches: newMatches,
        score: newScore,
        firstCardIndex: null,
        secondCardIndex: null,
        canFlip: true,
      );

      emit(newState);
      if (newState.isGameCompleted) {
        _stopTimer();
        emit(newState.copyWith(status: GameStatus.completed));
      }
    } else {
      updatedCards[event.firstCardIndex] = firstCard.copyWith(isFlipped: false);
      updatedCards[event.secondCardIndex] = secondCard.copyWith(isFlipped: false);
      
      emit(state.copyWith(
        cards: updatedCards,
        firstCardIndex: null,
        secondCardIndex: null,
        canFlip: true,
      ));
    }
  }

  void _onCheckMatch(CheckMatch event, Emitter<MemoryGameState> emit) {}

  void _onResetGame(ResetGame event, Emitter<MemoryGameState> emit) {
    _stopTimer();
    emit(const MemoryGameState());
  }

  void _onPauseGame(PauseGame event, Emitter<MemoryGameState> emit) {
    _stopTimer();
    emit(state.copyWith(status: GameStatus.paused));
  }

  void _onResumeGame(ResumeGame event, Emitter<MemoryGameState> emit) {
    _startTimer();
    emit(state.copyWith(status: GameStatus.playing));
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<MemoryGameState> emit) {
    final newScore = calculateScoreUseCase(
      matches: state.matches,
      moves: state.moves,
      elapsedTime: event.elapsedTime,
    );
    emit(state.copyWith(
      elapsedTime: event.elapsedTime,
      score: newScore,
    ));
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameStartTime != null) {
        final elapsed = DateTime.now().difference(_gameStartTime!);
        add(UpdateTimer(elapsed));
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}