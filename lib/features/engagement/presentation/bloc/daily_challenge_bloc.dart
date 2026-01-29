import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stake/features/engagement/domain/entities/daily_challenge.dart';
import '../../domain/services/engagement_service.dart';
import 'daily_challenge_event.dart';
import 'daily_challenge_state.dart';

class DailyChallengeBloc
    extends Bloc<DailyChallengeEvent, DailyChallengeState> {
  final EngagementService engagementService;

  DailyChallengeBloc({required this.engagementService})
    : super(const DailyChallengeInitial()) {
    on<LoadTodaysChallenge>(_onLoadTodaysChallenge);
    on<CompleteChallenge>(_onCompleteChallenge);
    on<RefreshChallenge>(_onRefreshChallenge);
    on<CheckChallengeCompletion>(_onCheckChallengeCompletion);
  }

  Future<void> _onLoadTodaysChallenge(
    LoadTodaysChallenge event,
    Emitter<DailyChallengeState> emit,
  ) async {
    try {
      emit(const DailyChallengeLoading());

      final challenge = await engagementService.getTodaysChallenge();

      if (challenge == null) {
        emit(const DailyChallengeEmpty());
        return;
      }

      emit(DailyChallengeLoaded(challenge: challenge));
    } catch (e) {
      emit(
        DailyChallengeError(
          message: 'Failed to load today\'s challenge',
          errorCode: 'LOAD_FAILED',
        ),
      );
    }
  }

  Future<void> _onCompleteChallenge(
    CompleteChallenge event,
    Emitter<DailyChallengeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengeLoaded) return;

    try {
      emit(DailyChallengeCompleting(challenge: currentState.challenge));

      final success = await engagementService.completeChallenge(
        challengeId: event.challengeId,
        gameData: event.gameData,
      );

      if (success) {
        // Get updated challenge to reflect completion status
        final updatedChallenge = await engagementService.getTodaysChallenge();

        if (updatedChallenge != null && updatedChallenge.isCompleted) {
          emit(
            DailyChallengeCompleted(
              challenge: updatedChallenge,
              earnedRewards: updatedChallenge.rewards,
            ),
          );
        } else {
          emit(
            DailyChallengeError(
              message: 'Challenge completion was not saved properly',
              errorCode: 'COMPLETION_NOT_SAVED',
            ),
          );
        }
      } else {
        emit(
          DailyChallengeError(
            message: 'Failed to complete challenge',
            errorCode: 'COMPLETION_FAILED',
          ),
        );

        // Return to loaded state
        emit(DailyChallengeLoaded(challenge: currentState.challenge));
      }
    } catch (e) {
      emit(
        DailyChallengeError(
          message: 'An error occurred while completing the challenge',
          errorCode: 'COMPLETION_ERROR',
        ),
      );

      // Return to loaded state
      emit(DailyChallengeLoaded(challenge: currentState.challenge));
    }
  }

  Future<void> _onRefreshChallenge(
    RefreshChallenge event,
    Emitter<DailyChallengeState> emit,
  ) async {
    // Force refresh by loading challenge again
    add(const LoadTodaysChallenge());
  }

  Future<void> _onCheckChallengeCompletion(
    CheckChallengeCompletion event,
    Emitter<DailyChallengeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengeLoaded) return;

    try {
      final canComplete = await engagementService.canCompleteChallenge(
        challengeId: event.challengeId,
        gameData: event.gameData,
      );

      emit(currentState.copyWith(canComplete: canComplete));
    } catch (e) {
      // Don't emit error for this, just keep current state
      // This is a non-critical check
    }
  }

  /// Helper method to check if challenge is completed
  bool get isChallengeCompleted {
    final currentState = state;
    if (currentState is DailyChallengeLoaded) {
      return currentState.challenge.isCompleted;
    }
    if (currentState is DailyChallengeCompleted) {
      return true;
    }
    return false;
  }

  /// Helper method to get current challenge
  DailyChallenge? get currentChallenge {
    final currentState = state;
    if (currentState is DailyChallengeLoaded) {
      return currentState.challenge;
    }
    if (currentState is DailyChallengeCompleted) {
      return currentState.challenge;
    }
    if (currentState is DailyChallengeCompleting) {
      return currentState.challenge;
    }
    return null;
  }

  /// Helper method to check if can complete challenge
  bool get canCompleteChallenge {
    final currentState = state;
    if (currentState is DailyChallengeLoaded) {
      return currentState.canComplete && !currentState.challenge.isCompleted;
    }
    return false;
  }
}
