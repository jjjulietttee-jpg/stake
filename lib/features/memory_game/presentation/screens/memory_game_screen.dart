import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/game_completion_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/game_state.dart';
import '../bloc/memory_game_bloc.dart';
import '../bloc/memory_game_event.dart';
import '../widgets/memory_card_widget.dart';
import '../widgets/game_stats_widget.dart';

class MemoryGameScreen extends StatelessWidget {
  const MemoryGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.secondaryDark,
              AppColors.accent.withValues(alpha: 0.1),
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const Expanded(
                      child: CustomText.title(
                        text: 'Memory Game',
                        textAlign: TextAlign.center,
                        hasGlow: true,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<MemoryGameBloc>().add(const PauseGame());
                        _showPauseDialog(context);
                      },
                      icon: const Icon(
                        Icons.pause,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Game Content
              Expanded(
                child: BlocConsumer<MemoryGameBloc, MemoryGameState>(
                  listener: (context, state) {
                    if (state.status == GameStatus.completed) {
                      // Record game completion for profile
                      getIt<GameCompletionService>().onGameCompleted(
                        gameType: 'memory_game',
                        score: state.score,
                        playTime: state.elapsedTime,
                      );
                      _showWinDialog(context, state);
                    }
                  },
                  builder: (context, state) {
                    if (state.status == GameStatus.initial) {
                      return _buildInitialState(context);
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Game Stats
                          GameStatsWidget(
                            moves: state.moves,
                            matches: state.matches,
                            totalPairs: state.totalPairs,
                            score: state.score,
                            elapsedTime: state.elapsedTime,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Game Grid
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: state.cards.length,
                              itemBuilder: (context, index) {
                                final card = state.cards[index];
                                return MemoryCardWidget(
                                  card: card,
                                  isEnabled: state.canFlip && state.status == GameStatus.playing,
                                  onTap: () {
                                    print('🎮 UI: Tapping card $index (icon: ${card.icon})');
                                    context.read<MemoryGameBloc>().add(FlipCard(index));
                                  },
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Control Buttons
                          Row(
                            children: [
                              Expanded(
                                child: CustomElevatedButton(
                                  text: 'New Game',
                                  backgroundColor: AppColors.buttonRed,
                                  onPressed: () {
                                    print('🎮 UI: New Game button pressed');
                                    context.read<MemoryGameBloc>().add(const StartGame(pairs: 6));
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomElevatedButton(
                                  text: 'Reset',
                                  backgroundColor: AppColors.cardBackground,
                                  onPressed: () {
                                    context.read<MemoryGameBloc>().add(const ResetGame());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 32),
            const CustomText.title(
              text: 'Memory Challenge',
              textAlign: TextAlign.center,
              hasGlow: true,
            ),
            const SizedBox(height: 16),
            const CustomText.body(
              text: 'Test your memory by matching pairs of cards. Flip two cards at a time and try to remember their positions!',
              textAlign: TextAlign.center,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 32),
            CustomElevatedButton(
              text: 'Start Game',
              backgroundColor: AppColors.accent,
              textColor: AppColors.primaryDark,
              height: 60,
              icon: Icons.play_arrow,
              onPressed: () {
                print('🎮 UI: Start Game button pressed (initial)');
                context.read<MemoryGameBloc>().add(const StartGame(pairs: 6));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWinDialog(BuildContext context, MemoryGameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        title: const CustomText.title(
          text: 'Congratulations!',
          textAlign: TextAlign.center,
          hasGlow: true,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 60,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            CustomText.body(
              text: 'You completed the game!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.2),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText.body(text: 'Score:'),
                      CustomText.body(
                        text: state.score.toString(),
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText.body(text: 'Moves:'),
                      CustomText.body(
                        text: state.moves.toString(),
                        color: AppColors.buttonRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomText.body(text: 'Time:'),
                      CustomText.body(
                        text: '${state.elapsedTime.inMinutes}:${(state.elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    print('🎮 UI: Play Again button pressed');
                    context.read<MemoryGameBloc>().add(const StartGame(pairs: 6));
                  },
                  child: const CustomText.body(
                    text: 'Play Again',
                    color: AppColors.accent,
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  },
                  child: const CustomText.body(
                    text: 'Back to Menu',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const CustomText.title(
          text: 'Game Paused',
          textAlign: TextAlign.center,
          hasGlow: true,
        ),
        content: const CustomText.body(
          text: 'The game is paused. Resume when you\'re ready!',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<MemoryGameBloc>().add(const ResumeGame());
                  },
                  child: const CustomText.body(
                    text: 'Resume',
                    color: AppColors.accent,
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  },
                  child: const CustomText.body(
                    text: 'Quit',
                    color: AppColors.buttonRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}