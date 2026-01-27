import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';

class MemoryGame extends StatefulWidget {
  final Function(int) onScoreUpdate;
  
  const MemoryGame({
    super.key,
    required this.onScoreUpdate,
  });

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame>
    with TickerProviderStateMixin {
  late List<MemoryCard> cards;
  late AnimationController _flipController;
  
  int? firstCardIndex;
  int? secondCardIndex;
  int matches = 0;
  int moves = 0;
  bool canFlip = true;

  final List<IconData> icons = [
    Icons.star,
    Icons.favorite,
    Icons.diamond,
    Icons.flash_on,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.cake,
    Icons.pets,
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _initializeGame();
  }

  void _initializeGame() {
    cards = [];
    List<IconData> gameIcons = [...icons, ...icons]; // Duplicate for pairs
    gameIcons.shuffle(Random());
    
    for (int i = 0; i < gameIcons.length; i++) {
      cards.add(MemoryCard(
        id: i,
        icon: gameIcons[i],
        isFlipped: false,
        isMatched: false,
      ));
    }
    
    matches = 0;
    moves = 0;
    firstCardIndex = null;
    secondCardIndex = null;
    canFlip = true;
  }

  void _onCardTap(int index) {
    if (!canFlip || cards[index].isFlipped || cards[index].isMatched) return;

    setState(() {
      cards[index].isFlipped = true;
      
      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else if (secondCardIndex == null) {
        secondCardIndex = index;
        moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    canFlip = false;
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (cards[firstCardIndex!].icon == cards[secondCardIndex!].icon) {
        // Match found
        setState(() {
          cards[firstCardIndex!].isMatched = true;
          cards[secondCardIndex!].isMatched = true;
          matches++;
          
          // Calculate score
          int score = (matches * 100) - (moves * 5);
          widget.onScoreUpdate(score > 0 ? score : 0);
        });
        
        if (matches == icons.length) {
          _showWinDialog();
        }
      } else {
        // No match
        setState(() {
          cards[firstCardIndex!].isFlipped = false;
          cards[secondCardIndex!].isFlipped = false;
        });
      }
      
      firstCardIndex = null;
      secondCardIndex = null;
      canFlip = true;
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const CustomText.title(
          text: 'Congratulations!',
          hasGlow: true,
        ),
        content: CustomText.body(
          text: 'You completed the game in $moves moves!',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomText.body(
              text: 'Moves: $moves',
              color: AppColors.accent,
            ),
            CustomText.body(
              text: 'Matches: $matches/${icons.length}',
              color: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Game grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: card.isMatched
                        ? LinearGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.3),
                              AppColors.accent.withValues(alpha: 0.1),
                            ],
                          )
                        : card.isFlipped
                            ? LinearGradient(
                                colors: [
                                  AppColors.buttonRed.withValues(alpha: 0.3),
                                  AppColors.buttonRed.withValues(alpha: 0.1),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.cardBackground,
                                  AppColors.secondaryDark,
                                ],
                              ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: card.isMatched
                          ? AppColors.accent
                          : AppColors.accent.withValues(alpha: 0.3),
                      width: card.isMatched ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: card.isFlipped || card.isMatched
                        ? Icon(
                            card.icon,
                            size: 32,
                            color: card.isMatched
                                ? AppColors.accent
                                : AppColors.buttonRed,
                          )
                        : Icon(
                            Icons.help_outline,
                            size: 32,
                            color: AppColors.textPrimary.withValues(alpha: 0.3),
                          ),
                  ),
                ),
              );
            },
          ),
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
    _flipController.dispose();
    super.dispose();
  }
}

class MemoryCard {
  final int id;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.icon,
    required this.isFlipped,
    required this.isMatched,
  });
}