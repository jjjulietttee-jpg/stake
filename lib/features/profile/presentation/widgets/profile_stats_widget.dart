import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';

class ProfileStatsWidget extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileStatsWidget({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Level and XP Progress
        CardWidget(
          hasGlow: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: 'Level ${userProfile.level}',
                        hasGlow: true,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: '${userProfile.experiencePoints} XP',
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: userProfile.levelProgress,
                backgroundColor: AppColors.cardBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomText(
                  text: '${(userProfile.levelProgress * 1000).toInt()}/1000 XP to next level',
                  fontSize: 12,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: CardWidget(
                hasGlow: true,
                child: Column(
                  children: [
                    const Icon(
                      Icons.score,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Total Score',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: userProfile.totalScore.toString(),
                        hasGlow: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.games,
                      size: 32,
                      color: AppColors.buttonRed,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Games Played',
                        color: AppColors.buttonRed,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: userProfile.gamesPlayed.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Play Time',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: userProfile.formattedPlayTime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Best Memory',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: (userProfile.gameStats['memory_game'] ?? 0).toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Engagement Stats Section
        const CustomText.subtitle(
          text: 'Daily Engagement',
          hasGlow: false,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CardWidget(
                hasGlow: true,
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 32,
                      color: AppColors.buttonRed,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Current Streak',
                        color: AppColors.buttonRed,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: '${userProfile.currentStreak} days',
                        hasGlow: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Longest Streak',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: '${userProfile.longestStreak} days',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Challenges',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: userProfile.totalChallengesCompleted.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CardWidget(
                child: Column(
                  children: [
                    const Icon(
                      Icons.article,
                      size: 32,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.body(
                        text: 'Bonus Content',
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: CustomText.subtitle(
                        text: userProfile.totalBonusContentViewed.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}