import '../entities/daily_bonus_content.dart';
import '../entities/engagement_profile.dart';
import '../repositories/engagement_repository.dart';
import '../services/engagement_analytics.dart';

class MarkBonusViewedUseCase {
  final EngagementRepository repository;
  final EngagementAnalytics analytics;

  MarkBonusViewedUseCase({
    required this.repository,
    required this.analytics,
  });

  Future<bool> call({
    required String contentId,
    required DateTime viewedAt,
  }) async {
    try {
      // Get current bonus content to verify it exists
      final bonusContent = await repository.getTodaysBonusContent();
      final content = bonusContent.firstWhere(
        (item) => item.id == contentId,
        orElse: () => throw Exception('Content not found'),
      );
      
      if (content.isViewed) {
        return false; // Already viewed
      }
      
      // Mark content as viewed
      await repository.markBonusContentViewed(contentId);
      
      // Update engagement profile
      await _updateEngagementProfile(content, viewedAt);
      
      // Record analytics
      await analytics.recordBonusContentViewed(
        contentId: contentId,
        contentType: content.type,
        contentTitle: content.title,
        viewedAt: viewedAt,
      );
      
      return true;
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  Future<void> _updateEngagementProfile(DailyBonusContent content, DateTime viewedAt) async {
    try {
      final profile = await repository.getEngagementProfile();
      
      // Update content type stats
      final updatedContentStats = Map<String, int>.from(profile.contentTypeStats);
      final contentTypeKey = content.type.name;
      updatedContentStats[contentTypeKey] = (updatedContentStats[contentTypeKey] ?? 0) + 1;
      
      // Check if this is the first engagement today
      final today = DateTime.now();
      final isFirstEngagementToday = !_isSameDay(profile.lastEngagementDate, today);
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (isFirstEngagementToday) {
        // Check if this continues a streak
        final yesterday = today.subtract(const Duration(days: 1));
        final wasActiveYesterday = _isSameDay(profile.lastEngagementDate, yesterday);
        
        if (wasActiveYesterday || profile.currentStreak == 0) {
          // Continue or start streak
          newCurrentStreak = profile.currentStreak + 1;
        } else {
          // Streak was broken, start new one
          newCurrentStreak = 1;
        }
        
        // Update longest streak if necessary
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
          // Record streak milestone
          await analytics.recordStreakMilestone(
            streakLength: newCurrentStreak,
            achievedAt: viewedAt,
          );
        }
      }
      
      final updatedProfile = profile.copyWith(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        totalBonusContentViewed: profile.totalBonusContentViewed + 1,
        lastEngagementDate: viewedAt,
        contentTypeStats: updatedContentStats,
      );
      
      await repository.updateEngagementProfile(updatedProfile);
      
      // Record daily engagement analytics
      await analytics.recordDailyEngagement(
        sessionDate: viewedAt,
        challengeCompleted: false, // This is just content viewing
        bonusContentViewed: 1,
        currentStreak: newCurrentStreak,
      );
      
    } catch (e) {
      // Log error in production but don't rethrow to avoid blocking content viewing
    }
  }

  /// Mark multiple content items as viewed
  Future<List<String>> markMultipleViewed({
    required List<String> contentIds,
    required DateTime viewedAt,
  }) async {
    final successfulIds = <String>[];
    
    for (final contentId in contentIds) {
      try {
        final success = await call(contentId: contentId, viewedAt: viewedAt);
        if (success) {
          successfulIds.add(contentId);
        }
      } catch (e) {
        // Log error but continue with other items
      }
    }
    
    return successfulIds;
  }

  /// Get viewing statistics
  Future<Map<String, int>> getViewingStats() async {
    try {
      final profile = await repository.getEngagementProfile();
      return {
        'total_viewed': profile.totalBonusContentViewed,
        ...profile.contentTypeStats,
      };
    } catch (e) {
      // Log error in production
      return {};
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}