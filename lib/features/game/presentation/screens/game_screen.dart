import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isGameStarted = false;
  int _score = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _simulateGameAction() {
    setState(() {
      _score += 100;
      if (_score % 500 == 0) {
        _level++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.secondaryDark,
              AppColors.buttonRed.withValues(alpha: 0.1),
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Game App Bar
            SliverAppBar(
              expandedHeight: 150,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const CustomText.subtitle(
                  text: 'Game Zone',
                  hasGlow: true,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        AppColors.buttonRed.withValues(alpha: 0.3),
                        AppColors.secondaryDark.withValues(alpha: 0.8),
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: const Center(
                          child: Icon(
                            Icons.sports_esports,
                            size: 60,
                            color: AppColors.buttonRed,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Game content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!_isGameStarted) ...[
                    // Game preview
                    const CustomText.title(
                      text: 'Ready for Adventure?',
                      textAlign: TextAlign.center,
                      hasGlow: true,
                    ),
                    const SizedBox(height: 16),
                    CustomText.body(
                      text: 'This is a demo version of the game. Full version will be available in the next update.',
                      textAlign: TextAlign.center,
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 32),
                    
                    // Game preview card
                    CardWidget(
                      hasGlow: true,
                      onTap: () => context.push('/memory-game'),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
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
                              size: 50,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const CustomText.subtitle(
                            text: 'Memory Game',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          CustomText.body(
                            text: 'Test your memory with card matching',
                            textAlign: TextAlign.center,
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Start game button
                    CustomElevatedButton(
                      text: 'PLAY MEMORY GAME',
                      backgroundColor: AppColors.buttonRed,
                      height: 80,
                      icon: Icons.psychology,
                      onPressed: () => context.push('/memory-game'),
                    ),
                  ] else ...[
                    // Game interface
                    Row(
                      children: [
                        Expanded(
                          child: CardWidget(
                            child: Column(
                              children: [
                                const CustomText.body(
                                  text: 'Score',
                                  color: AppColors.accent,
                                ),
                                const SizedBox(height: 8),
                                CustomText.title(
                                  text: _score.toString(),
                                  hasGlow: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CardWidget(
                            child: Column(
                              children: [
                                const CustomText.body(
                                  text: 'Level',
                                  color: AppColors.accent,
                                ),
                                const SizedBox(height: 8),
                                CustomText.title(
                                  text: _level.toString(),
                                  hasGlow: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Game area
                    CardWidget(
                      hasGlow: true,
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.accent.withValues(alpha: 0.5),
                                        AppColors.buttonRed.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.extension,
                                    size: 60,
                                    color: AppColors.accent,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const CustomText.subtitle(
                            text: 'Game Field',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          CustomText.body(
                            text: 'Tap the button below to play',
                            textAlign: TextAlign.center,
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Game action button
                    CustomElevatedButton(
                      text: 'PLAY TURN',
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.primaryDark,
                      height: 70,
                      icon: Icons.refresh,
                      onPressed: _simulateGameAction,
                    ),
                    const SizedBox(height: 16),
                    
                    // Stop game button
                    CustomElevatedButton(
                      text: 'END GAME',
                      backgroundColor: AppColors.cardBackground,
                      onPressed: () {
                        setState(() {
                          _isGameStarted = false;
                        });
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Game features
                  const CustomText.subtitle(
                    text: 'Game Features',
                    hasGlow: false,
                  ),
                  const SizedBox(height: 16),
                  
                  CardWidget(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.accent,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.body(
                                text: 'Bonus Rounds',
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 4),
                              CustomText(
                                text: 'Increase your score multiplier',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  CardWidget(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: AppColors.buttonRed,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.body(
                                text: 'Progressive Levels',
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 4),
                              CustomText(
                                text: 'Increasing difficulty and rewards',
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}