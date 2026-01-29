import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/theme/app_theme.dart';

class EngagementHomeWidget extends StatelessWidget {
  const EngagementHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText.subtitle(
          text: 'Daily Engagement',
          hasGlow: false,
        ),
        const SizedBox(height: 16),
        
        // Daily Challenge Card
        CardWidget(
          hasGlow: true,
          onTap: () => context.push('/daily-challenge'),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.buttonRed.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 32,
                  color: AppColors.buttonRed,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.body(
                      text: 'Daily Challenge',
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4),
                    CustomText(
                      text: 'Complete today\'s challenge for rewards',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Daily Bonus Card
        CardWidget(
          hasGlow: true,
          onTap: () => context.push('/daily-bonus'),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
                  Icons.auto_awesome,
                  size: 32,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.body(
                      text: 'Daily Bonus',
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4),
                    CustomText(
                      text: 'Discover today\'s tips and insights',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}