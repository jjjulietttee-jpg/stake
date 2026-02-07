import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<bool> getOnboardingCompleted() async {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboarding_completed', value);
  }

  Future<String?> getPlayerName() async {
    return _prefs.getString('player_name');
  }

  Future<void> setPlayerName(String name) async {
    await _prefs.setString('player_name', name);
  }

  Future<int> getGamesPlayed() async {
    return _prefs.getInt('games_played') ?? 0;
  }

  Future<void> setGamesPlayed(int count) async {
    await _prefs.setInt('games_played', count);
  }

  Future<int> getBestScore() async {
    return _prefs.getInt('best_score') ?? 0;
  }

  Future<void> setBestScore(int score) async {
    await _prefs.setInt('best_score', score);
  }

  Future<Map<String, dynamic>> getAchievementsProgress() async {
    final String? json = _prefs.getString('achievements_progress');
    if (json == null) return {};
    try {
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> setAchievementsProgress(Map<String, dynamic> progress) async {
  }

  Future<void> setAchievementProgress(String achievementId, double progress) async {
    await _prefs.setDouble('achievement_$achievementId', progress);
  }

  Future<double> getAchievementProgress(String achievementId) async {
    return _prefs.getDouble('achievement_$achievementId') ?? 0.0;
  }

  Future<void> setAchievementCompleted(String achievementId, bool completed) async {
    await _prefs.setBool('achievement_${achievementId}_completed', completed);
  }

  Future<bool> getAchievementCompleted(String achievementId) async {
    return _prefs.getBool('achievement_${achievementId}_completed') ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
