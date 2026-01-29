import '../../domain/entities/engagement_profile.dart';

class EngagementProfileModel {
  final int currentStreak;
  final int longestStreak;
  final int totalChallengesCompleted;
  final int totalBonusContentViewed;
  final String lastEngagementDate;
  final Map<String, int> challengeTypeStats;
  final Map<String, int> contentTypeStats;

  const EngagementProfileModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalChallengesCompleted,
    required this.totalBonusContentViewed,
    required this.lastEngagementDate,
    required this.challengeTypeStats,
    required this.contentTypeStats,
  });

  factory EngagementProfileModel.fromJson(Map<String, dynamic> json) {
    return EngagementProfileModel(
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalChallengesCompleted: json['totalChallengesCompleted'] as int,
      totalBonusContentViewed: json['totalBonusContentViewed'] as int,
      lastEngagementDate: json['lastEngagementDate'] as String,
      challengeTypeStats: Map<String, int>.from(json['challengeTypeStats'] as Map),
      contentTypeStats: Map<String, int>.from(json['contentTypeStats'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalChallengesCompleted': totalChallengesCompleted,
      'totalBonusContentViewed': totalBonusContentViewed,
      'lastEngagementDate': lastEngagementDate,
      'challengeTypeStats': challengeTypeStats,
      'contentTypeStats': contentTypeStats,
    };
  }

  EngagementProfile toEntity() {
    return EngagementProfile(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalChallengesCompleted: totalChallengesCompleted,
      totalBonusContentViewed: totalBonusContentViewed,
      lastEngagementDate: DateTime.parse(lastEngagementDate),
      challengeTypeStats: challengeTypeStats,
      contentTypeStats: contentTypeStats,
    );
  }

  factory EngagementProfileModel.fromEntity(EngagementProfile profile) {
    return EngagementProfileModel(
      currentStreak: profile.currentStreak,
      longestStreak: profile.longestStreak,
      totalChallengesCompleted: profile.totalChallengesCompleted,
      totalBonusContentViewed: profile.totalBonusContentViewed,
      lastEngagementDate: profile.lastEngagementDate.toIso8601String(),
      challengeTypeStats: profile.challengeTypeStats,
      contentTypeStats: profile.contentTypeStats,
    );
  }
}