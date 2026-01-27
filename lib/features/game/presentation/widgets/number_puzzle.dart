import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/theme/app_theme.dart';

class NumberPuzzle extends StatefulWidget {
  final Function(int) onScoreUpdate;
  
  const NumberPuzzle({
    super.key,
    required this.onScoreUpdate,
  });

  @override
  State<NumberPuzzle> createState() => _NumberPuzzleState();
}

class _NumberPuzzleState extends State<NumberPuzzle>
    with TickerProviderStateMixin {
  late List<int> tiles;
  late AnimationController _moveController;
  
  int moves = 0;
  int emptyIndex = 15;
  
  final List<int> solvedState = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0];

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializeGame();
  }

  void _initializeGame() {
    tiles = List.from(solvedState);
    _shuffleTiles();
    moves = 0;
  }

  void _shuffleTiles() {
    // Shuffle the puzzle ensuring it's solvable
    for (int i = 0; i < 1000; i++) {
      List<int> validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        int randomMove = validMoves[Random().nextInt(validMoves.length)];
        _moveTile(randomMove, false); // Don't count shuffle moves
      }
    }
  }

  List<int> _getValidMoves() {
    List<int> validMoves = [];
    int row = emptyIndex ~/ 4;
    int col = emptyIndex % 4;
    
    // Up
    if (row > 0) validMoves.add(emptyIndex - 4);
    // Down
    if (row < 3) validMoves.add(emptyIndex + 4);
    // Left
    if (col > 0) validMoves.add(emptyIndex - 1);
    // Right
    if (col < 3) validMoves.add(emptyIndex + 1);
    
    return validMoves;
  }

  void _moveTile(int tileIndex, bool countMove) {
    if (_getValidMoves().contains(tileIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[tileIndex];
        tiles[tileIndex] = 0;
        emptyIndex = tileIndex;
        
        if (countMove) {
          moves++;
          _updateScore();
        }
      });
      
      _moveController.forward().then((_) {
        _moveController.reset();
      });
      
      if (_isPuzzleSolved()) {
        _showWinDialog();
      }
    }
  }

  void _updateScore() {
    int score = max(0, 1000 - (moves * 10));
    widget.onScoreUpdate(score);
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != solvedState[i]) return false;
    }
    return true;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const CustomText.title(
          text: 'Puzzle Solved!',
          hasGlow: true,
        ),
        content: CustomText.body(
          text: 'You solved the puzzle in $moves moves!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeGame();
              });
            },
            child: const CustomText.body(
              text: 'Play Again',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Game info
        CustomText.body(
          text: 'Moves: $moves',
          color: AppColors.accent,
        ),
        const SizedBox(height: 20),
        
        // Game grid
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cardBackground,
                    AppColors.secondaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  int tileValue = tiles[index];
                  bool isEmpty = tileValue == 0;
                  
                  return GestureDetector(
                    onTap: isEmpty ? null : () => _moveTile(index, true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isEmpty
                            ? null
                            : LinearGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.8),
                                  AppColors.accent.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(8),
                        border: isEmpty
                            ? null
                            : Border.all(
                                color: AppColors.accent,
                                width: 1,
                              ),
                        boxShadow: isEmpty
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: isEmpty
                          ? null
                          : Center(
                              child: CustomText.title(
                                text: tileValue.toString(),
                                color: AppColors.primaryDark,
                                hasGlow: false,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Instructions
        const CustomText.body(
          text: 'Tap tiles to move them into the empty space',
          textAlign: TextAlign.center,
          color: AppColors.textPrimary,
        ),
        
        const SizedBox(height: 20),
        
        // Reset button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _initializeGame();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primaryDark,
          ),
          child: const CustomText.body(
            text: 'New Game',
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }
}