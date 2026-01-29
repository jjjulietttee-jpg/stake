import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/card_widget.dart';
import '../../../../core/shared/widgets/custom_text.dart';
import '../../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/daily_bonus_content.dart';
import '../bloc/daily_bonus_bloc.dart';
import '../bloc/daily_bonus_event.dart';
import '../bloc/daily_bonus_state.dart';

class DailyBonusScreen extends StatefulWidget {
  const DailyBonusScreen({super.key});

  @override
  State<DailyBonusScreen> createState() => _DailyBonusScreenState();
}

class _DailyBonusScreenState extends State<DailyBonusScreen> {
  ContentType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load today's bonus content when screen opens
    context.read<DailyBonusBloc>().add(const LoadTodaysBonusContent());
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
                  text: 'Daily Bonus',
                  hasGlow: true,
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<DailyBonusBloc>().add(const RefreshBonusContent());
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
              ],
            ),
            // Filter Tabs
            SliverToBoxAdapter(
              child: _buildFilterTabs(),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: BlocBuilder<DailyBonusBloc, DailyBonusState>(
                builder: (context, state) {
                  return _buildContent(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Tips', ContentType.gameTip),
            const SizedBox(width: 8),
            _buildFilterChip('Facts', ContentType.funFact),
            const SizedBox(width: 8),
            _buildFilterChip('Achievements', ContentType.achievement),
            const SizedBox(width: 8),
            _buildFilterChip('Milestones', ContentType.milestone),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ContentType? type) {
    final isSelected = _selectedFilter == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
        context.read<DailyBonusBloc>().add(FilterBonusContentByType(contentType: type));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: CustomText(
          text: label,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyBonusState state) {
    if (state is DailyBonusLoading) {
      return _buildLoadingState();
    }
    
    if (state is DailyBonusError) {
      return _buildErrorState(context, state);
    }
    
    if (state is DailyBonusEmpty) {
      return _buildEmptyState(state);
    }
    
    if (state is DailyBonusLoaded) {
      return _buildLoadedState(context, state);
    }
    
    if (state is DailyBonusViewing) {
      return _buildViewingState(context, state);
    }
    
    if (state is DailyBonusContentViewed) {
      return _buildContentViewedState(context, state);
    }
    
    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CircularProgressIndicator(
            color: AppColors.accent,
          ),
          const SizedBox(height: 24),
          const CustomText.body(
            text: 'Loading bonus content...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DailyBonusError state) {
    return SliverToBoxAdapter(
      child: Column(
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
                CustomText.body(
                  text: state.message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomElevatedButton(
                  text: 'Try Again',
                  icon: Icons.refresh,
                  onPressed: () {
                    context.read<DailyBonusBloc>().add(const LoadTodaysBonusContent());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DailyBonusEmpty state) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 50),
          CardWidget(
            child: Column(
              children: [
                const Icon(
                  Icons.inbox,
                  size: 64,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                const CustomText.subtitle(
                  text: 'No Content Available',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText.body(
                  text: state.message,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CustomText.body(
            text: 'Welcome to Daily Bonus Content!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomElevatedButton(
            text: 'Load Content',
            icon: Icons.auto_awesome,
            onPressed: () {
              context.read<DailyBonusBloc>().add(const LoadTodaysBonusContent());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, DailyBonusLoaded state) {
    final contentToShow = state.filteredContent;
    
    if (contentToShow.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 50),
            CardWidget(
              child: Column(
                children: [
                  const Icon(
                    Icons.filter_list_off,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  const CustomText.body(
                    text: 'No content matches the selected filter',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomElevatedButton(
                    text: 'Clear Filter',
                    onPressed: () {
                      setState(() {
                        _selectedFilter = null;
                      });
                      context.read<DailyBonusBloc>().add(const FilterBonusContentByType());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            // Header with stats
            return Column(
              children: [
                _buildStatsHeader(state),
                const SizedBox(height: 16),
              ],
            );
          }
          
          final contentIndex = index - 1;
          if (contentIndex >= contentToShow.length) return null;
          
          final content = contentToShow[contentIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildContentCard(context, content, state),
          );
        },
        childCount: contentToShow.length + 1,
      ),
    );
  }

  Widget _buildViewingState(BuildContext context, DailyBonusViewing state) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CircularProgressIndicator(
            color: AppColors.accent,
          ),
          const SizedBox(height: 24),
          const CustomText.body(
            text: 'Marking content as viewed...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentViewedState(BuildContext context, DailyBonusContentViewed state) {
    // This state is transient, it will quickly transition to loaded state
    return _buildLoadedState(context, DailyBonusLoaded(
      content: state.content,
      unviewedCount: state.unviewedCount,
    ));
  }

  Widget _buildStatsHeader(DailyBonusLoaded state) {
    return CardWidget(
      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: '${state.content.length}',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
                const CustomText(
                  text: 'Total',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textPrimary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.fiber_new,
                  color: state.unviewedCount > 0 ? AppColors.buttonRed : AppColors.textPrimary.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: '${state.unviewedCount}',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: state.unviewedCount > 0 ? AppColors.buttonRed : AppColors.textPrimary.withValues(alpha: 0.5),
                ),
                const CustomText(
                  text: 'New',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, DailyBonusContent content, DailyBonusLoaded state) {
    final isViewed = content.isViewed;
    final isBeingViewed = context.read<DailyBonusBloc>().isContentBeingViewed(content.id);
    
    return CardWidget(
      hasGlow: !isViewed,
      backgroundColor: isViewed 
          ? AppColors.cardBackground.withValues(alpha: 0.7)
          : null,
      onTap: !isViewed && !isBeingViewed ? () {
        context.read<DailyBonusBloc>().add(MarkBonusContentViewed(contentId: content.id));
      } : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getContentTypeColor(content.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getContentTypeIcon(content.type),
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    CustomText(
                      text: _getContentTypeLabel(content.type),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isViewed)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 20,
                )
              else if (!isViewed)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonRed,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Title
          CustomText.body(
            text: content.title,
            fontWeight: FontWeight.bold,
            hasGlow: !isViewed,
          ),
          const SizedBox(height: 12),
          
          // Content Body
          CustomText.body(
            text: content.content,
            color: AppColors.textPrimary.withValues(alpha: isViewed ? 0.6 : 0.9),
          ),
          
          if (!isViewed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                if (isBeingViewed)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                else
                  const Row(
                    children: [
                      CustomText(
                        text: 'Tap to read',
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.gameTip:
        return AppColors.accent;
      case ContentType.funFact:
        return Colors.blue;
      case ContentType.achievement:
        return Colors.purple;
      case ContentType.milestone:
        return Colors.green;
    }
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.gameTip:
        return Icons.lightbulb;
      case ContentType.funFact:
        return Icons.psychology;
      case ContentType.achievement:
        return Icons.emoji_events;
      case ContentType.milestone:
        return Icons.flag;
    }
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.gameTip:
        return 'TIP';
      case ContentType.funFact:
        return 'FACT';
      case ContentType.achievement:
        return 'ACHIEVEMENT';
      case ContentType.milestone:
        return 'MILESTONE';
    }
  }
}