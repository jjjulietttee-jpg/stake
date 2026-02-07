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

  const SplashReadyToNavigate({
    required this.hasRemoteContent,
    required this.contentUrl,
  });

  @override
  List<Object?> get props => [hasRemoteContent, contentUrl];
}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
