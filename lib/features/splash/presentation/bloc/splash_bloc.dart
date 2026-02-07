import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final StorageService storageService;

  SplashBloc({required this.storageService}) : super(const SplashInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<NavigateToNextScreen>(_onNavigateToNextScreen);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashLoading());
      await Future.delayed(const Duration(seconds: 2));
      final onboardingCompleted = await storageService.getOnboardingCompleted();
      
      emit(SplashReadyToNavigate(
        shouldShowOnboarding: !onboardingCompleted,
      ));
    } catch (e) {
      emit(SplashError('Failed to check onboarding status: ${e.toString()}'));
    }
  }

  Future<void> _onNavigateToNextScreen(
    NavigateToNextScreen event,
    Emitter<SplashState> emit,
  ) async {}
}
