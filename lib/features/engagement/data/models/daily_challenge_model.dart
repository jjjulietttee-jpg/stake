import '../../domain/entities/daily_challenge.dart';

class RewardModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final int value;

  const RewardModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'value': value,
    };
  }

  Reward toEntity() {
    return Reward(
      id: id,
      type: RewardType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => RewardType.points,
      ),
      title: title,
      description: description,
      value: value,
    );
  }

  factory RewardModel.fromEntity(Reward reward) {
    return RewardModel(
      id: reward.id,
      type: reward.type.name,
      title: reward.title,
      description: reward.description,
      value: reward.value,
    );
  }
}

class DailyChallengeModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final Map<String, dynamic> parameters;
  final String date;
  final bool isCompleted;
  final List<RewardModel> rewards;

  const DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.parameters,
    required this.date,
    required this.isCompleted,
    required this.rewards,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      date: json['date'] as String,
      isCompleted: json['isCompleted'] as bool,
      rewards: (json['rewards'] as List)
          .map((reward) => RewardModel.fromJson(reward as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'parameters': parameters,
      'date': date,
      'isCompleted': isCompleted,
      'rewards': rewards.map((reward) => reward.toJson()).toList(),
    };
  }

  DailyChallenge toEntity() {
    return DailyChallenge(
      id: id,
      title: title,
      description: description,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ChallengeType.playGames,
      ),
      parameters: parameters,
      date: DateTime.parse(date),
      isCompleted: isCompleted,
      rewards: rewards.map((reward) => reward.toEntity()).toList(),
    );
  }

  factory DailyChallengeModel.fromEntity(DailyChallenge challenge) {
    return DailyChallengeModel(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      type: challenge.type.name,
      parameters: challenge.parameters,
      date: challenge.date.toIso8601String(),
      isCompleted: challenge.isCompleted,
      rewards: challenge.rewards
          .map((reward) => RewardModel.fromEntity(reward))
          .toList(),
    );
  }
}