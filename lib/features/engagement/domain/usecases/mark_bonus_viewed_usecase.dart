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
      final bonusContent = await repository.getTodaysBonusContent();
      final content = bonusContent.firstWhere(
        (item) => item.id == contentId,
        orElse: () => throw Exception('Content not found'),
      );
      
      if (content.isViewed) {
        return false; // Already viewed
      }
      
      await repository.markBonusContentViewed(contentId);
      
      await _updateEngagementProfile(content, viewedAt);
      
      await analytics.recordBonusContentViewed(
        contentId: contentId,
        contentType: content.type,
        contentTitle: content.title,
        viewedAt: viewedAt,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateEngagementProfile(DailyBonusContent content, DateTime viewedAt) async {
    try {
      final profile = await repository.getEngagementProfile();
      
      final updatedContentStats = Map<String, int>.from(profile.contentTypeStats);
      final contentTypeKey = content.type.name;
      updatedContentStats[contentTypeKey] = (updatedContentStats[contentTypeKey] ?? 0) + 1;
      
      final today = DateTime.now();
      final isFirstEngagementToday = !_isSameDay(profile.lastEngagementDate, today);
      
      int newCurrentStreak = profile.currentStreak;
      int newLongestStreak = profile.longestStreak;
      
      if (isFirstEngagementToday) {
        final yesterday = today.subtract(const Duration(days: 1));
        final wasActiveYesterday = _isSameDay(profile.lastEngagementDate, yesterday);
        
        if (wasActiveYesterday || profile.currentStreak == 0) {
          newCurrentStreak = profile.currentStreak + 1;
        } else {
          newCurrentStreak = 1;
        }
        
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
          
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
      
      await analytics.recordDailyEngagement(
        sessionDate: viewedAt,
        challengeCompleted: false, // This is just content viewing
        bonusContentViewed: 1,
        currentStreak: newCurrentStreak,
      );
      
    } catch (e) {
    }
  }

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
      }
    }
    
    return successfulIds;
  }

  Future<Map<String, int>> getViewingStats() async {
    try {
      final profile = await repository.getEngagementProfile();
      return {
        'total_viewed': profile.totalBonusContentViewed,
        ...profile.contentTypeStats,
      };
    } catch (e) {
      return {};
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}