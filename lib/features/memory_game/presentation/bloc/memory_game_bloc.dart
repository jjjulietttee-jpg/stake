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
    print('🎮 Starting new game with ${event.pairs} pairs');
    final cards = startGameUseCase(pairs: event.pairs);
    print('🎮 Generated ${cards.length} cards');
    
    // Debug: print all cards
    for (int i = 0; i < cards.length; i++) {
      print('🎮 Card $i: ${cards[i].icon} (isFlipped: ${cards[i].isFlipped}, isMatched: ${cards[i].isMatched})');
    }
    
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
    
    print('🎮 Game started! Total cards: ${cards.length}, Pairs to find: ${event.pairs}');
  }

  void _onFlipCard(FlipCard event, Emitter<MemoryGameState> emit) {
    print('🎮 FlipCard event: cardIndex=${event.cardIndex}');
    print('🎮 Current state: canFlip=${state.canFlip}, firstCard=${state.firstCardIndex}, secondCard=${state.secondCardIndex}');
    
    // Проверяем можно ли переворачивать карточку
    if (!state.canFlip || 
        state.cards[event.cardIndex].isFlipped || 
        state.cards[event.cardIndex].isMatched) {
      print('🎮 ❌ Cannot flip card: canFlip=${state.canFlip}');
      return;
    }

    // ЗАЩИТА: Проверяем есть ли уже открытые карточки, но firstCardIndex == null
    final openCards = <int>[];
    for (int i = 0; i < state.cards.length; i++) {
      if (state.cards[i].isFlipped && !state.cards[i].isMatched) {
        openCards.add(i);
      }
    }
    
    print('🎮 Open cards found: $openCards');

    // Создаем копию карточек
    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[event.cardIndex] = updatedCards[event.cardIndex].copyWith(isFlipped: true);

    if (openCards.isEmpty) {
      // Нет открытых карточек - это первая
      print('🎮 ✅ First card flipped: ${event.cardIndex}');
      emit(state.copyWith(
        cards: updatedCards,
        firstCardIndex: event.cardIndex,
        secondCardIndex: null,
      ));
    } else if (openCards.length == 1 && openCards[0] != event.cardIndex) {
      // Есть одна открытая карточка - это вторая
      final firstCardIndex = openCards[0];
      final secondCardIndex = event.cardIndex;
      
      print('🎮 ✅ Second card flipped: $secondCardIndex (first was $firstCardIndex)');
      
      // Обновляем состояние со второй карточкой и блокируем флипы
      emit(state.copyWith(
        cards: updatedCards,
        firstCardIndex: firstCardIndex,
        secondCardIndex: secondCardIndex,
        moves: state.moves + 1,
        canFlip: false, // Блокируем новые флипы
      ));
      
      // Запускаем проверку через 1 секунду
      print('🎮 ⏳ Checking match in 1 second... firstCard=$firstCardIndex, secondCard=$secondCardIndex');
      Timer(const Duration(milliseconds: 1000), () {
        add(CheckMatchWithIndices(firstCardIndex, secondCardIndex));
      });
    } else if (openCards.contains(event.cardIndex)) {
      // Нажали на уже открытую карточку - игнорируем
      print('🎮 ❌ Ignoring tap: card already open');
    } else {
      // У нас уже есть две открытые карточки - игнорируем
      print('🎮 ❌ Ignoring tap: already have ${openCards.length} open cards');
    }
  }

  void _onCheckMatchWithIndices(CheckMatchWithIndices event, Emitter<MemoryGameState> emit) {
    print('🎮 CheckMatchWithIndices: ${event.firstCardIndex} vs ${event.secondCardIndex}');
    
    // Проверяем что индексы валидны
    if (event.firstCardIndex >= state.cards.length || event.secondCardIndex >= state.cards.length) {
      print('🎮 ❌ Invalid card indices');
      return;
    }

    final firstCard = state.cards[event.firstCardIndex];
    final secondCard = state.cards[event.secondCardIndex];
    final updatedCards = List<MemoryCard>.from(state.cards);

    print('🎮 Comparing: Card ${event.firstCardIndex} (${firstCard.icon}) vs Card ${event.secondCardIndex} (${secondCard.icon})');

    if (firstCard.icon == secondCard.icon) {
      // Совпадение найдено
      print('🎮 ✅ MATCH FOUND!');
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

      // Проверяем завершение игры
      if (newState.isGameCompleted) {
        print('🎮 🎉 GAME COMPLETED!');
        _stopTimer();
        emit(newState.copyWith(status: GameStatus.completed));
      }
    } else {
      // Совпадения нет - закрываем карточки
      print('🎮 ❌ NO MATCH. Closing cards ${event.firstCardIndex} and ${event.secondCardIndex}');
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

  void _onCheckMatch(CheckMatch event, Emitter<MemoryGameState> emit) {
    print('🎮 ⚠️ Old CheckMatch event triggered - this should not happen!');
    // Этот метод больше не должен использоваться
  }

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
    
    // ВАЖНО: НЕ сбрасываем firstCardIndex и secondCardIndex при обновлении таймера!
    emit(state.copyWith(
      elapsedTime: event.elapsedTime,
      score: newScore,
      // НЕ передаем firstCardIndex и secondCardIndex - они должны сохраниться
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