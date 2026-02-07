import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSplash extends SplashEvent {
  const InitializeSplash();
}

class SplashAnimationCompleted extends SplashEvent {
  const SplashAnimationCompleted();
}
