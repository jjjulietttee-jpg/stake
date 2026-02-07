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
      await dailyResetService.checkAndPerformDailyReset();

      var bonusContent = await repository.getTodaysBonusContent();

      if (bonusContent.isEmpty) {
        final today = DateTime.now();
        bonusContent = bonusContentProvider.generateDailyContent(today);

        if (repository is EngagementRepositoryImpl) {
          await (repository as EngagementRepositoryImpl).saveTodaysBonusContent(
            bonusContent,
          );
        }
      }

      return bonusContent;
    } catch (e) {
      try {
        final today = DateTime.now();
        return bonusContentProvider.getFallbackContent(today);
      } catch (fallbackError) {
        return [];
      }
    }
  }

  Future<List<DailyBonusContent>> getUnviewedContent() async {
    try {
      final allContent = await call();
      return allContent.where((content) => !content.isViewed).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DailyBonusContent>> getContentByType(ContentType type) async {
    try {
      final allContent = await call();
      return allContent.where((content) => content.type == type).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> hasNewContent() async {
    try {
      final unviewedContent = await getUnviewedContent();
      return unviewedContent.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
