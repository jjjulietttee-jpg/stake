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
  final bool hasRemoteContent;
  final String contentUrl;
  final bool showOnboarding;

  const SplashReadyToNavigate({
    required this.hasRemoteContent,
    required this.contentUrl,
    required this.showOnboarding,
  });

  @override
  List<Object?> get props => [hasRemoteContent, contentUrl, showOnboarding];
}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
