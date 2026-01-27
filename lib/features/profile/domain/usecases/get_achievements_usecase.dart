import '../entities/achievement.dart';
import '../repositories/profile_repository.dart';

class GetAchievementsUseCase {
  final ProfileRepository repository;

  GetAchievementsUseCase(this.repository);

  Future<List<Achievement>> call() async {
    return await repository.getAchievements();
  }
}