import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/services/storage_service.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final StorageService storageService;
  final RemoteConfigService remoteConfigService;

  bool _animationDone = false;
  bool? _remoteAvailable;
  bool _onboardingDone = true;
  bool _emitted = false;

  SplashBloc({
    required this.storageService,
    required this.remoteConfigService,
  }) : super(const SplashInitial()) {
    on<InitializeSplash>(_onInitialize);
    on<SplashAnimationCompleted>(_onAnimationCompleted);
  }

  Future<void> _onInitialize(
    InitializeSplash event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashLoading());
      _remoteAvailable = await _checkRemoteConfig();
      _onboardingDone = await _checkOnboarding();
      _tryEmitReady(emit);
    } catch (_) {
      _remoteAvailable = false;
      _onboardingDone = true;
      _tryEmitReady(emit);
    }
  }

  Future<void> _onAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) async {
    _animationDone = true;
    _tryEmitReady(emit);
  }

  void _tryEmitReady(Emitter<SplashState> emit) {
    if (_emitted || !_animationDone || _remoteAvailable == null) return;
    _emitted = true;
    try {
      emit(SplashReadyToNavigate(
        hasRemoteContent: _remoteAvailable ?? false,
        contentUrl: remoteConfigService.resolvedEndpoint,
        showOnboarding: !_onboardingDone,
      ));
    } catch (_) {
      emit(const SplashReadyToNavigate(
        hasRemoteContent: false,
        contentUrl: '',
        showOnboarding: false,
      ));
    }
  }

  Future<bool> _checkRemoteConfig() async {
    try {
      return await remoteConfigService.fetchAvailability();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkOnboarding() async {
    try {
      return await storageService.getOnboardingCompleted();
    } catch (_) {
      return true;
    }
  }
}
