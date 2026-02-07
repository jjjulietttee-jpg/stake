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
import '../widgets/achievement_card_widget.dart';
import '../../domain/entities/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(const LoadAchievementsOnly()),
      child: const _AchievementsScreenContent(),
    );
  }
}

class _AchievementsScreenContent extends StatefulWidget {
  const _AchievementsScreenContent();

  @override
  State<_AchievementsScreenContent> createState() => _AchievementsScreenContentState();
}

class _AchievementsScreenContentState extends State<_AchievementsScreenContent>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Achievement> _filterAchievements(List<Achievement> achievements, AchievementRarity? rarity) {
    if (rarity == null) return achievements;
    return achievements.where((a) => a.rarity == rarity).toList();
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
                      text: 'Error Loading Achievements',
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
                        context.read<ProfileBloc>().add(const LoadAchievementsOnly());
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is AchievementsOnlyLoaded || state is ProfileLoaded) {
              final achievements = state is AchievementsOnlyLoaded 
                  ? state.achievements 
                  : (state as ProfileLoaded).achievements;
              final unlockedCount = achievements.where((a) => a.isUnlocked).length;

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
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
                      title: const CustomText.subtitle(
                        text: 'Achievements',
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
                              const Icon(
                                Icons.emoji_events,
                                size: 80,
                                color: AppColors.accent,
                              ),
                              const SizedBox(height: 8),
                              CustomText.body(
                                text: '$unlockedCount/${achievements.length} Unlocked',
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Common'),
                        Tab(text: 'Rare'),
                        Tab(text: 'Epic+'),
                      ],
                      labelColor: AppColors.accent,
                      unselectedLabelColor: AppColors.textPrimary.withValues(alpha: 0.6),
                      indicatorColor: AppColors.accent,
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAchievementsList(achievements),
                        _buildAchievementsList(_filterAchievements(achievements, AchievementRarity.common)),
                        _buildAchievementsList(_filterAchievements(achievements, AchievementRarity.rare)),
                        _buildAchievementsList([
                          ..._filterAchievements(achievements, AchievementRarity.epic),
                          ..._filterAchievements(achievements, AchievementRarity.legendary),
                        ]),
                      ],
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

  Widget _buildAchievementsList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 16),
            CustomText.body(
              text: 'No achievements in this category',
              color: AppColors.textPrimary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: achievements.length + 1, // +1 for bottom spacing
      itemBuilder: (context, index) {
        if (index == achievements.length) {
          return const SizedBox(height: 80); // Bottom spacing
        }

        final achievement = achievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AchievementCardWidget(
            achievement: achievement,
            showAnimation: true,
          ),
        );
      },
    );
  }
}