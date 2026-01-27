import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_stats_widget.dart';
import '../../domain/entities/achievement.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(const LoadProfileOnly()),
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  final ScrollController _scrollController = ScrollController();

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
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.buttonRed,
                    ),
                    const SizedBox(height: 16),
                    CustomText.subtitle(
                      text: 'Error Loading Profile',
                      color: AppColors.buttonRed,
                    ),
                    const SizedBox(height: 8),
                    CustomText.body(
                      text: state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomElevatedButton(
                      text: 'Retry',
                      onPressed: () {
                        context.read<ProfileBloc>().add(const LoadProfileOnly());
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileOnlyLoaded || state is ProfileLoaded) {
              final userProfile = state is ProfileOnlyLoaded 
                  ? state.userProfile 
                  : (state as ProfileLoaded).userProfile;
              
              // Load achievements in background for quick stats
              if (state is ProfileOnlyLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<ProfileBloc>().add(const LoadAchievements());
                  }
                });
              }
              
              final achievements = state is ProfileLoaded ? state.achievements : <Achievement>[];
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Profile App Bar
                  SliverAppBar(
                    expandedHeight: 200,
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
                      title: CustomText.subtitle(
                        text: userProfile.name,
                        hasGlow: true,
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [
                              AppColors.accent.withValues(alpha: 0.3),
                              AppColors.secondaryDark.withValues(alpha: 0.8),
                              AppColors.primaryDark,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.cardBackground,
                                child: CustomText.title(
                                  text: userProfile.name[0].toUpperCase(),
                                  hasGlow: true,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomText.body(
                                text: 'Level ${userProfile.level}',
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Profile content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Player stats
                        const CustomText.title(
                          text: 'Player Statistics',
                          textAlign: TextAlign.center,
                          hasGlow: true,
                        ),
                        const SizedBox(height: 24),
                        ProfileStatsWidget(userProfile: userProfile),
                        const SizedBox(height: 32),

                        // Achievements section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText.title(
                              text: 'Quick Stats',
                              hasGlow: true,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                text: 'View Achievements',
                                backgroundColor: AppColors.accent,
                                icon: Icons.emoji_events,
                                onPressed: () => context.push('/achievements'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Quick Achievement Preview
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withValues(alpha: 0.2),
                                AppColors.accent.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText.subtitle(
                                    text: 'Achievement Progress',
                                    hasGlow: true,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: CustomText.body(
                                      text: achievements.isNotEmpty 
                                          ? '${achievements.where((a) => a.isUnlocked).length}/${achievements.length}'
                                          : 'Loading...',
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: achievements.isNotEmpty 
                                    ? achievements.where((a) => a.isUnlocked).length / achievements.length
                                    : 0.0,
                                backgroundColor: AppColors.cardBackground,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickStat(
                                      'Recent Unlocks',
                                      achievements.isNotEmpty
                                          ? achievements
                                              .where((a) => a.isUnlocked && a.unlockedAt != null)
                                              .where((a) => DateTime.now().difference(a.unlockedAt!).inDays < 7)
                                              .length
                                              .toString()
                                          : '0',
                                      Icons.new_releases,
                                      AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildQuickStat(
                                      'Total XP Earned',
                                      achievements.isNotEmpty
                                          ? achievements
                                              .where((a) => a.isUnlocked)
                                              .fold<int>(0, (sum, a) => sum + a.xpReward)
                                              .toString()
                                          : '0',
                                      Icons.star,
                                      AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),

                  // Bottom actions
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                text: 'Refresh Profile',
                                backgroundColor: AppColors.accent,
                                icon: Icons.refresh,
                                onPressed: () {
                                  context.read<ProfileBloc>().add(const RefreshProfile());
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: CustomElevatedButton(
                                text: 'Back to Game',
                                backgroundColor: AppColors.cardBackground,
                                icon: Icons.games,
                                onPressed: () => context.pop(),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CustomText(
            text: value,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CustomText(
            text: title,
            fontSize: 12,
            color: AppColors.textPrimary.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}