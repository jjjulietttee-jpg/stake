import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_challenge.dart';

abstract class DailyChallengeState extends Equatable {
  const DailyChallengeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DailyChallengeInitial extends DailyChallengeState {
  const DailyChallengeInitial();
}

/// Loading challenge
class DailyChallengeLoading extends DailyChallengeState {
  const DailyChallengeLoading();
}

/// Challenge loaded successfully
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

/// Challenge completion in progress
class DailyChallengeCompleting extends DailyChallengeState {
  final DailyChallenge challenge;

  const DailyChallengeCompleting({required this.challenge});

  @override
  List<Object?> get props => [challenge];
}

/// Challenge completed successfully
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

/// No challenge available
class DailyChallengeEmpty extends DailyChallengeState {
  final String message;

  const DailyChallengeEmpty({
    this.message = 'No challenge available today',
  });

  @override
  List<Object?> get props => [message];
}

/// Error state
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