import 'package:equatable/equatable.dart';

class EngagementProfile extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalChallengesCompleted;
  final int totalBonusContentViewed;
  final DateTime lastEngagementDate;
  final Map<String, int> challengeTypeStats; // challenge type -> completed count
  final Map<String, int> contentTypeStats; // content type -> viewed count

  const EngagementProfile({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalChallengesCompleted,
    required this.totalBonusContentViewed,
    required this.lastEngagementDate,
    required this.challengeTypeStats,
    required this.contentTypeStats,
  });

  EngagementProfile copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalChallengesCompleted,
    int? totalBonusContentViewed,
    DateTime? lastEngagementDate,
    Map<String, int>? challengeTypeStats,
    Map<String, int>? contentTypeStats,
  }) {
    return EngagementProfile(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalChallengesCompleted: totalChallengesCompleted ?? this.totalChallengesCompleted,
      totalBonusContentViewed: totalBonusContentViewed ?? this.totalBonusContentViewed,
      lastEngagementDate: lastEngagementDate ?? this.lastEngagementDate,
      challengeTypeStats: challengeTypeStats ?? this.challengeTypeStats,
      contentTypeStats: contentTypeStats ?? this.contentTypeStats,
    );
  }

  static EngagementProfile empty() {
    return EngagementProfile(
      currentStreak: 0,
      longestStreak: 0,
      totalChallengesCompleted: 0,
      totalBonusContentViewed: 0,
      lastEngagementDate: DateTime.now(),
      challengeTypeStats: {},
      contentTypeStats: {},
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalChallengesCompleted,
        totalBonusContentViewed,
        lastEngagementDate,
        challengeTypeStats,
        contentTypeStats,
      ];
}