import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_challenge.dart';

abstract class DailyChallengeState extends Equatable {
  const DailyChallengeState();

  @override
  List<Object?> get props => [];
}

class DailyChallengeInitial extends DailyChallengeState {
  const DailyChallengeInitial();
}

class DailyChallengeLoading extends DailyChallengeState {
  const DailyChallengeLoading();
}

class DailyChallengeLoaded extends DailyChallengeState {
  final DailyChallenge challenge;
  final bool canComplete;

  const DailyChallengeLoaded({
    required this.challenge,
    this.canComplete = false,
  });

  @override
  List<Object?> get props => [challenge, canComplete];

  DailyChallengeLoaded copyWith({
    DailyChallenge? challenge,
    bool? canComplete,
  }) {
    return DailyChallengeLoaded(
      challenge: challenge ?? this.challenge,
      canComplete: canComplete ?? this.canComplete,
    );
  }
}

class DailyChallengeCompleting extends DailyChallengeState {
  final DailyChallenge challenge;

  const DailyChallengeCompleting({required this.challenge});

  @override
  List<Object?> get props => [challenge];
}

class DailyChallengeCompleted extends DailyChallengeState {
  final DailyChallenge challenge;
  final List<Reward> earnedRewards;

  const DailyChallengeCompleted({
    required this.challenge,
    required this.earnedRewards,
  });

  @override
  List<Object?> get props => [challenge, earnedRewards];
}

class DailyChallengeEmpty extends DailyChallengeState {
  final String message;

  const DailyChallengeEmpty({
    this.message = 'No challenge available today',
  });

  @override
  List<Object?> get props => [message];
}

class DailyChallengeError extends DailyChallengeState {
  final String message;
  final String? errorCode;

  const DailyChallengeError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}