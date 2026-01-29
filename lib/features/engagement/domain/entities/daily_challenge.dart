import 'package:equatable/equatable.dart';

enum ChallengeType {
  playGames,
  achieveScore,
  playTime,
  perfectGame,
  streak,
}

enum RewardType {
  badge,
  points,
  streak,
}

class Reward extends Equatable {
  final String id;
  final RewardType type;
  final String title;
  final String description;
  final int value;

  const Reward({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
  });

  @override
  List<Object?> get props => [id, type, title, description, value];
}

class DailyChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final Map<String, dynamic> parameters;
  final DateTime date;
  final bool isCompleted;
  final List<Reward> rewards;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.parameters,
    required this.date,
    required this.isCompleted,
    required this.rewards,
  });

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    Map<String, dynamic>? parameters,
    DateTime? date,
    bool? isCompleted,
    List<Reward>? rewards,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      rewards: rewards ?? this.rewards,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        parameters,
        date,
        isCompleted,
        rewards,
      ];
}