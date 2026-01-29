import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/daily_challenge.dart';
import '../bloc/daily_challenge_bloc.dart';
import '../bloc/daily_challenge_event.dart';
import '../bloc/daily_challenge_state.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's challenge when screen opens
    context.read<DailyChallengeBloc>().add(const LoadTodaysChallenge());
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
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              flexibleSpace: const FlexibleSpaceBar(
                title: CustomText.subtitle(
                  text: 'Daily Challenge',
                  hasGlow: true,
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<DailyChallengeBloc>().add(
                      const RefreshChallenge(),
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
              ],
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BlocBuilder<DailyChallengeBloc, DailyChallengeState>(
                    builder: (context, state) {
                      return _buildContent(context, state);
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyChallengeState state) {
    if (state is DailyChallengeLoading) {
      return _buildLoadingState();
    }

    if (state is DailyChallengeError) {
      return _buildErrorState(context, state);
    }

    if (state is DailyChallengeEmpty) {
      return _buildEmptyState(state);
    }

    if (state is DailyChallengeLoaded) {
      return _buildLoadedState(context, state);
    }

    if (state is DailyChallengeCompleting) {
      return _buildCompletingState(state);
    }

    if (state is DailyChallengeCompleted) {
      return _buildCompletedState(context, state);
    }

    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CircularProgressIndicator(color: AppColors.accent),
        const SizedBox(height: 24),
        const CustomText.body(
          text: 'Loading today\'s challenge...',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, DailyChallengeError state) {
    return Column(
      children: [
        const SizedBox(height: 50),
        CardWidget(
          hasGlow: true,
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.buttonRed,
              ),
              const SizedBox(height: 16),
              const CustomText.subtitle(
                text: 'Oops!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomText.body(text: state.message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CustomElevatedButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: () {
                  context.read<DailyChallengeBloc>().add(
                    const LoadTodaysChallenge(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(DailyChallengeEmpty state) {
    return Column(
      children: [
        const SizedBox(height: 50),
        CardWidget(
          child: Column(
            children: [
              const Icon(Icons.event_busy, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              const CustomText.subtitle(
                text: 'No Challenge Today',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomText.body(text: state.message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CustomText.body(
          text: 'Welcome to Daily Challenges!',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CustomElevatedButton(
          text: 'Load Challenge',
          icon: Icons.play_arrow,
          onPressed: () {
            context.read<DailyChallengeBloc>().add(const LoadTodaysChallenge());
          },
        ),
      ],
    );
  }

  Widget _buildLoadedState(BuildContext context, DailyChallengeLoaded state) {
    final challenge = state.challenge;

    return Column(
      children: [
        // Challenge Card
        CardWidget(
          hasGlow: !challenge.isCompleted,
          backgroundColor: challenge.isCompleted
              ? AppColors.cardBackground.withValues(alpha: 0.7)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getChallengeTypeColor(challenge.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomText(
                      text: _getChallengeTypeLabel(challenge.type),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (challenge.isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Challenge Title
              CustomText.subtitle(
                text: challenge.title,
                hasGlow: !challenge.isCompleted,
              ),
              const SizedBox(height: 8),

              // Challenge Description
              CustomText.body(
                text: challenge.description,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),

              // Challenge Progress/Status
              _buildChallengeProgress(challenge),

              const SizedBox(height: 20),

              // Rewards Section
              if (challenge.rewards.isNotEmpty) ...[
                const CustomText.body(
                  text: 'Rewards:',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                ...challenge.rewards.map((reward) => _buildRewardItem(reward)),
                const SizedBox(height: 16),
              ],

              // Action Button
              if (!challenge.isCompleted)
                CustomElevatedButton(
                  text: 'Start Playing',
                  icon: Icons.play_arrow,
                  backgroundColor: AppColors.buttonRed,
                  onPressed: () {
                    // Navigate to game screen
                    context.push('/game');
                  },
                )
              else
                CustomElevatedButton(
                  text: 'Challenge Completed!',
                  icon: Icons.check,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.3),
                  textColor: AppColors.accent,
                  onPressed: null,
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tips Card
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  CustomText.body(text: 'Tips', fontWeight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 12),
              CustomText.body(
                text: _getChallengeTypeTip(challenge.type),
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletingState(DailyChallengeCompleting state) {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CircularProgressIndicator(color: AppColors.accent),
        const SizedBox(height: 24),
        const CustomText.body(
          text: 'Completing challenge...',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    DailyChallengeCompleted state,
  ) {
    return Column(
      children: [
        // Celebration Card
        CardWidget(
          hasGlow: true,
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          child: Column(
            children: [
              const Icon(Icons.celebration, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              const CustomText.title(
                text: 'Challenge Completed!',
                textAlign: TextAlign.center,
                hasGlow: true,
              ),
              const SizedBox(height: 8),
              CustomText.body(
                text: 'Congratulations! You\'ve completed today\'s challenge.',
                textAlign: TextAlign.center,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 20),

              // Earned Rewards
              if (state.earnedRewards.isNotEmpty) ...[
                const CustomText.body(
                  text: 'Rewards Earned:',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                ...state.earnedRewards.map(
                  (reward) => _buildRewardItem(reward, isEarned: true),
                ),
                const SizedBox(height: 20),
              ],

              CustomElevatedButton(
                text: 'Continue Playing',
                icon: Icons.play_arrow,
                onPressed: () => context.push('/game'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeProgress(DailyChallenge challenge) {
    if (challenge.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.accent, size: 20),
            SizedBox(width: 8),
            CustomText.body(
              text: 'Completed',
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.buttonRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.buttonRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.timer, color: AppColors.buttonRed, size: 20),
          SizedBox(width: 8),
          CustomText.body(
            text: 'In Progress',
            fontWeight: FontWeight.bold,
            color: AppColors.buttonRed,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(Reward reward, {bool isEarned = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            _getRewardIcon(reward.type),
            color: isEarned
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText(
              text: '${reward.title}: ${reward.description}',
              fontSize: 14,
              color: isEarned
                  ? AppColors.accent
                  : AppColors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getChallengeTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.playGames:
        return AppColors.buttonRed;
      case ChallengeType.achieveScore:
        return AppColors.accent;
      case ChallengeType.playTime:
        return Colors.blue;
      case ChallengeType.perfectGame:
        return Colors.purple;
      case ChallengeType.streak:
        return Colors.green;
    }
  }

  String _getChallengeTypeLabel(ChallengeType type) {
    switch (type) {
      case ChallengeType.playGames:
        return 'PLAY';
      case ChallengeType.achieveScore:
        return 'SCORE';
      case ChallengeType.playTime:
        return 'TIME';
      case ChallengeType.perfectGame:
        return 'PERFECT';
      case ChallengeType.streak:
        return 'STREAK';
    }
  }

  String _getChallengeTypeTip(ChallengeType type) {
    switch (type) {
      case ChallengeType.playGames:
        return 'Play multiple games to complete this challenge. Each game counts towards your progress!';
      case ChallengeType.achieveScore:
        return 'Focus on getting a high score in any game. Take your time and aim for accuracy!';
      case ChallengeType.playTime:
        return 'Spend time playing games today. Every minute counts towards this challenge!';
      case ChallengeType.perfectGame:
        return 'Complete a game without making any mistakes. Patience and focus are key!';
      case ChallengeType.streak:
        return 'Keep playing daily to maintain your streak. Consistency is rewarded!';
    }
  }

  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.badge:
        return Icons.military_tech;
      case RewardType.points:
        return Icons.stars;
      case RewardType.streak:
        return Icons.local_fire_department;
    }
  }
}
