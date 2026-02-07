import 'package:equatable/equatable.dart';

abstract class DailyChallengeEvent extends Equatable {
  const DailyChallengeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodaysChallenge extends DailyChallengeEvent {
  const LoadTodaysChallenge();
}

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

class RefreshChallenge extends DailyChallengeEvent {
  const RefreshChallenge();
}

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