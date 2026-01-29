import 'package:stake/features/engagement/data/repositories/engagement_repository_impl.dart';

import '../entities/daily_bonus_content.dart';
import '../repositories/engagement_repository.dart';
import '../services/bonus_content_provider.dart';
import '../services/daily_reset_service.dart';

class GetTodaysBonusContentUseCase {
  final EngagementRepository repository;
  final BonusContentProvider bonusContentProvider;
  final DailyResetService dailyResetService;

  GetTodaysBonusContentUseCase({
    required this.repository,
    required this.bonusContentProvider,
    required this.dailyResetService,
  });

  Future<List<DailyBonusContent>> call() async {
    try {
      // Check if daily reset is needed
      await dailyResetService.checkAndPerformDailyReset();

      // Try to get existing bonus content
      var bonusContent = await repository.getTodaysBonusContent();

      // If no content exists, generate new content
      if (bonusContent.isEmpty) {
        final today = DateTime.now();
        bonusContent = bonusContentProvider.generateDailyContent(today);

        // Save the generated content
        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
            bonusContent,
          );
        }
      }

      return bonusContent;
    } catch (e) {
      // If all else fails, try to get fallback content
      try {
        final today = DateTime.now();
        return bonusContentProvider.getFallbackContent(today);
      } catch (fallbackError) {
        // Log both errors in production
        return [];
      }
    }
  }

  /// Get only unviewed bonus content
  Future<List<DailyBonusContent>> getUnviewedContent() async {
    try {
      final allContent = await call();
      return allContent.where((content) => !content.isViewed).toList();
    } catch (e) {
      // Log error in production
      return [];
    }
  }

  /// Get content by type
  Future<List<DailyBonusContent>> getContentByType(ContentType type) async {
    try {
      final allContent = await call();
      return allContent.where((content) => content.type == type).toList();
    } catch (e) {
      // Log error in production
      return [];
    }
  }

  /// Check if there's new content available
  Future<bool> hasNewContent() async {
    try {
      final unviewedContent = await getUnviewedContent();
      return unviewedContent.isNotEmpty;
    } catch (e) {
      // Log error in production
      return false;
    }
  }
}
