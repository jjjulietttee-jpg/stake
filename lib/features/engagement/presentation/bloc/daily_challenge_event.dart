import 'package:equatable/equatable.dart';

abstract class DailyChallengeEvent extends Equatable {
  const DailyChallengeEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's daily challenge
class LoadTodaysChallenge extends DailyChallengeEvent {
  const LoadTodaysChallenge();
}

/// Complete the current daily challenge
class CompleteChallenge extends DailyChallengeEvent {
  final String challengeId;
  final Map<String, dynamic>? gameData;

  const CompleteChallenge({
    required this.challengeId,
    this.gameData,
  });

  @override
  List<Object?> get props => [challengeId, gameData];
}

/// Refresh the challenge (force reload)
class RefreshChallenge extends DailyChallengeEvent {
  const RefreshChallenge();
}

/// Check if challenge can be completed with given game data
class CheckChallengeCompletion extends DailyChallengeEvent {
  final String challengeId;
  final Map<String, dynamic> gameData;

  const CheckChallengeCompletion({
    required this.challengeId,
    required this.gameData,
  });

  @override
  List<Object?> get props => [challengeId, gameData];
}