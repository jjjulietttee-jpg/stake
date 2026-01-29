import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashReadyToNavigate extends SplashState {
  final bool shouldShowOnboarding;
  
  const SplashReadyToNavigate({required this.shouldShowOnboarding});
  
  @override
  List<Object?> get props => [shouldShowOnboarding];
}

class SplashError extends SplashState {
  final String message;
  
  const SplashError(this.message);
  
  @override
  List<Object?> get props => [message];
}
